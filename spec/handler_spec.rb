require 'spec_helper'
require 'base64'

describe SQS::Job::Handler do
  let(:message_type){ 'dummy' }
  let(:message_params){ {'foo' => 'bar'} }
  let(:message_hash){ { type: message_type, params: message_params } }
  let(:message_body){ JSON.generate(message_hash) }
  let(:key) { KEY }
  let(:message_attributes) {
    {
      'key_fingerprint' => {
        string_value: key.fingerprint
      },
      'signature' => {
        string_value: Base64.strict_encode64(key.sign(message_body))
      }
    }
  }
  let(:sqs_message){ double('AWS::SQS::Message', body: message_body, message_attributes: message_attributes) }
  let(:message_instance){ double('message instance', :"invoke!" => 'invoked', :"valid?" => true) }
  let(:message_class){ double('message class', new: message_instance) }
  let(:handler){ SQS::Job::Handler.new sqs_message }
  subject { handler }

  before do
    allow(handler).to receive(:require).and_call_original
    allow(handler).to receive(:require).with("sqs/job/message/dummy")
    stub_const("SQS::Job::Message::Dummy", message_class)
    allow(SQS::Job).to receive(:signing_keys).and_return [ key ]
  end
  
  describe "#run!" do
    context "when message does not contain 'type'" do
      let(:message_hash){ {} }
      it "fails the message permanently" do
        expect{ handler.run! }.to raise_error(MissingTypeException)
      end
    end
    
    context "when type is 'base'" do
      let(:message_type){ 'base' }
      it "fails the message permanently" do
        expect{ handler.run! }.to raise_error(UnrecognizedMessageTypeException, 'base')
      end
    end
    
    context "when type is present" do
      context "with invalid message signature" do
        before do
          expect(SQS::Job).to receive(:signing_keys).and_return [ ]
        end
        it "fails the message permanently" do
          expect{ subject.run! }.to raise_error(SignatureInvalidException)
        end
      end
      
      context "with an unknown type" do
        let(:message_type){ 'foobar' }
        it "fails the message permanently" do
          expect{ handler.run! }.to raise_error(UnrecognizedMessageTypeException, 'foobar')
        end
      end
      
      context "with an invalid message" do
        it "fails the message permanently" do
          allow(message_instance).to receive(:valid?).and_return false
          expect(message_instance).to receive(:errors).and_return double('errors', full_messages: ['full-messages'])
          expect(message_instance).not_to receive(:invoke!)
          expect{ subject.run! }.to raise_error(InvalidMessageException, "full-messages")
        end
      end
      
      context "with a valid message" do
        it "requires 'sqs/job/message/dummy'" do
          expect(handler).to receive(:require).with('sqs/job/message/dummy').and_return true
          subject.run!
        end
        
        it "creates a message instance message body's params" do
          expect(message_class).to receive(:new).with(message_params)
          subject.run!
        end
        
        it "calls invoke! on the message instance" do
          expect(message_instance).to receive(:invoke!)
          subject.run!
        end
      end
    end
  end
end
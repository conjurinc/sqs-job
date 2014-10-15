require 'spec_helper'
require 'base64'

describe SQS::Job::Handler do
  let(:message_type){ 'dummy' }
  let(:message_params){ {'foo' => 'bar'} }
  let(:message_hash){ { type: message_type, params: message_params, message_id: 'message id' } }
  let(:message_body){ JSON.generate(message_hash) }
  let(:sqs_message){ double('AWS::SQS::Message', body: Base64.encode64(message_body)) }
  let(:message_instance){ double('message instance', :"invoke!" => 'invoked', :"valid?" => true) }
  let(:message_class){ double('message class', new: message_instance) }
  let(:handler){ SQS::Job::Handler.new sqs_message }
  subject { handler }

  before do
    # This feels a bit strange, but I think it's ok.
    allow(handler).to receive(:require)
    stub_const("SQS::Job::Message::Dummy", message_class)
  end
  
  describe "#run!" do
    context "when message does not contain 'type'" do
      let(:message_hash){ {} }
      it "raises an exception" do
        expect{ handler.run! }.to raise_error
      end
    end
    
    context "when type is 'base'" do
      let(:message_type){ 'base' }
      it "raises an exception" do
        expect{ handler.run! }.to raise_error
      end
    end
    
    context "when type is present" do
      context "with an invalid message" do
        it "ignores the message" do
          allow(message_instance).to receive(:valid?).and_return false
          expect(message_instance).to receive(:errors).and_return double('errors', full_messages: ['full-messages'])
          expect(message_instance).not_to receive(:invoke!)
          subject.run!
        end
      end
      
      context "with a valid message" do
        it "requires 'sqs/job/message/dummy'" do
          expect(handler).to receive(:require).with('sqs/job/message/dummy').and_return true
          subject.run!
        end
        
        it "creates a message instance message body's params and message_id" do
          expect(message_class).to receive(:new).with(message_params, 'message id')
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
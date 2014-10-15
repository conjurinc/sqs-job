module SQS::Job
  # One Handler instance is created per SQS message 
  # received, and is responsible for processing it 
  # by instantiating a Message::Base subclass and 
  # calling its #invoke! method.  The "main" method
  # is #run!.
  #
  # Messages have the following structure:
  # {type: 'create', params: { ... }}
  # Where params is optional (for example, keepalive messages
  # might not have params).
  #
  # The message class is loaded by requiring 'vm2/message/#{type}'
  # constantizing it in the normal way, and passing the params hash
  # to #new.
  class Handler
    def initialize sqs_message
      @sqs_message = sqs_message
    end
    
    # Run this handler
    def run!
      require 'base64'
      json = JSON.parse Base64.decode64 @sqs_message.body
      raise "Missing message type in #{json}" unless (type = json['type'])
      klass = message_class type
      SQS::Job.logger.info "Received message #{klass}"
      message_id = json['message_id'] || SecureRandom.uuid
      message = klass.new(json['params'] || {}, message_id)
      unless message.valid?
        SQS::Job.logger.warn "Invalid message: #{message.errors.full_messages.join(', ')}"
        return false
      end
      message.invoke!
    end
    
    private
    
    def message_class type
      # This seems simpler than trying to fake abstract classes in ruby
      raise "invalid type: #{type}" if type == 'base'
      
      # This would be the place to implement a message whitelist
      
      message_file = "sqs/job/message/#{type}"
      
      # We might do some caching here at some point...the only reason
      # I'm not adding it now is that the multithreaded environment makes
      # it slightly less than a freebie
      require message_file
      
      message_file.gsub(/^sqs/, 'SQS').classify.constantize
    end
  end
end
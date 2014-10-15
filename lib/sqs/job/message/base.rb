require 'validatable'

module SQS::Job
  module Message
    # Base class for messages.  A Message::Base subclass
    # must implement an #invoke! method which performs the
    # appropriate operation.
    class Base 
      include Validatable
      
      def initialize params, message_id
        # We allow messages with no params field
        @params = (params || {}).symbolize_keys.freeze
        @message_id = message_id
      end
      
      # Parameters for the message.  This Hash is frozen.
      attr_reader :params
      
      # Id of this message.  Used to send replies.
      attr_reader :message_id
      
      # Get a parameter or raise an exception if it's not present
      # @param name [Symbol,String] the param name
      def param! name
        params[name.to_sym] or raise "Missing parameter #{name}"
      end
      
      # Type field for this message.  Used primarily when sending 
      # replies.
      def type
        self.class.name.split('::')[-1].underscore
      end
    end
  end
end
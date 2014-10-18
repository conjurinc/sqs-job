require "sqs/job/version"
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'json'

module SQS
  module Job
    class << self
      def send_message type, parameters
        require 'base64'

        message = {
          "type" => type,
          "params" => parameters
        }.to_json
        signature   = signing_key.sign message
        fingerprint = signing_key.fingerprint
        message_attributes = {
          "signature" => {
            "string_value" => Base64.strict_encode64(signature),
            "data_type" => "String",
          },
          "key_fingerprint" => {
            "string_value" => fingerprint,
            "data_type" => "String"
          }
        }
        queue.send_message message, message_attributes: message_attributes
      end
      
      def signature_valid? message, fingerprint, signature
        !signing_keys.find do |k|
          k.fingerprint == fingerprint && k.verify_signature(message, signature)
        end.nil?
      end
      
      def min_threads
        ENV['SQS_JOB_MIN_THREADS'] || 1
      end
      
      def max_threads
        ENV['SQS_JOB_MAX_THREADS'] || 10
      end
      
      def sqs=(sqs); @sqs = sqs; end
      def sqs
        @sqs ||= AWS::SQS::new
      end
      
      def signing_keys=(keys); @signing_keys = keys; end
      def signing_keys; @signing_keys or raise "No signing keys are configured"; end
      
      def queue_name=(name); @queue_name = name; end

        def queue
        @queue ||= sqs.queues[queue_name]
      end
      
      def logger=(logger); @logger = logger; end
      def logger
        @logger ||= Logger.new(STDERR)
      end
    end
  end
end

require 'sqs/job/exceptions'
require 'sqs/job/worker'
require 'sqs/job/handler'
require 'sqs/job/message/base'
require 'sqs/job/provisioner'

if defined?(Conjur)
  require 'sqs/job/policy'
end

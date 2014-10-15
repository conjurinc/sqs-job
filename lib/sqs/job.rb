require "sqs/job/version"
require 'logger'
require 'active_support'
require 'active_support/core_ext'
require 'json'

module SQS
  module Job
    class << self
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
      
      def outbound_queue_name=(name); @outbound_queue_name = name; end
        
      def outbound_queue
        @outbound_queue ||= sqs.queues[outbound_queue_name]
      end
      
      def inbound_queue_name=(name); @inbound_queue_name = name; end

      def inbound_queue
        @inbound_queue ||= sqs.queues[inbound_queue_name]
      end
      
      def logger=(logger); @logger = logger; end
      def logger
        @logger ||= Logger.new(STDERR)
      end
    end
  end
end

require 'sqs/job/worker'
require 'sqs/job/handler'

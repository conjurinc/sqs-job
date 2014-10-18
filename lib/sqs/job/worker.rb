module SQS::Job
  # A Worker maintains a SQS::Job::ThreadPool and AWS::SQS::Queue
  # and creates SQS::Job::Handler instances to process each message
  # received.  It is also responsible for boot/configuration 
  # stuff.  There should only be one worker per process.
  class Worker
    def run queue, options = {}
      require 'sqs/job/thread_pool'

      min_threads = options[:min_threads] || SQS::Job.min_threads 
      max_threads = options[:max_threads] || SQS::Job.max_threads
      @pool = SQS::Job::ThreadPool.new min_threads, max_threads do |msg|
        log_exceptions{ Handler.new(msg).run! }
      end
      
      while true
        # KEG: it's not clear if queue.poll accepts message_attribute_names
        queue.receive_messages(wait_time_seconds: 10, batch_size: 10, message_attribute_names: [ 'signature', 'key_fingerprint' ]) do |msg|
          @pool << msg
        end
      end
    end
    
    def log_exceptions &block
      begin
        block.call
      rescue => ex
        SQS::Job.logger.error "Error processing message: #{ex}\n\t#{ex.backtrace.join("\t\n")}"
        raise ex unless ex.is_a?(UnrecoverableException)
      end
    end
  end
end

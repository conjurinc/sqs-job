module SQS::Job
  # A Worker maintains a SQS::Job::ThreadPool and AWS::SQS::Queue
  # and creates SQS::Job::Handler instances to process each message
  # received.  It is also responsible for boot/configuration 
  # stuff.  There should only be one worker per process.
  class Worker
    def run
      require 'sqs/job/thread_pool'
      
      @pool = SQS::Job::ThreadPool.new SQS::Job.min_threads, SQS::Job.min_threads do |msg|
        log_exceptions{ Handler.new(msg).run! }
      end
      
      SQS::Job.inbound_queue.poll(wait_time_seconds: nil) do |msg|
        @pool << msg
      end
    end
    
    def log_exceptions &block
      begin
        block.call
      rescue => ex
        SQS::Job.logger.error "Error handling message: #{ex}\n#{ex.backtrace.join("\n")}"
        raise ex
      end
    end
  end
end
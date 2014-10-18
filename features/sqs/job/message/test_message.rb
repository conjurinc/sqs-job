module SQS::Job::Message
  class TestMessage < Base
    def invoke!
      $messages_received << TestMessage
    end
  end
end
module SQS::Job
  Provisoner = Struct.new(:conjur, :policy_id) do
    # Create a signing key (Slosilo::Key) and store it in +variable_name+/public and +variable_name+/private.
    def create_signing_key queue_name
      require 'slosilo'
      signing_key = Slosilo::Key.new
      conjur.variable([ policy_id, SQS::Job::Policy.public_variable_name(queue_name)  ].join('/')).add_value signing_key.key.public_key.to_pem
      conjur.variable([ policy_id, SQS::Job::Policy.private_variable_name(queue_name) ].join('/')).add_value signing_key.key.to_pem
      nil
    end
    
    # Configure a user policy to send to the sqs_queue.
    def permit_queue_send user, sqs_queue
      user.policies['send_to_queue'] = JSON.pretty_generate({
        "Statement" => [
          "Effect" => "Allow",
          "Action" => [ "sqs:SendMessage" ],
          "Resource" => [ sqs_queue.arn ]
        ]})
      user.policies['info'] = info_policy
    end
    
    # Configure a user policy to receive from the sqs_queue.
    def permit_queue_receive user, sqs_queue
      user.policies['receive_from_queue'] = JSON.pretty_generate({
        "Statement" => [
          "Effect" => "Allow",
          "Action" => [ "sqs:ReceiveMessage", "sqs:DeleteMessage", "sqs:ChangeMessageVisibility" ],
          "Resource" => [ sqs_queue.arn ]
        ]})
      user.policies['info'] = info_policy
    end
    
    protected
    
    def info_policy
      JSON.pretty_generate({
      "Statement" => [
        "Effect" => "Allow",
        "Action" => [ "sqs:ListQueues", "sqs:GetQueueUrl" ],
        "Resource" => [ "*" ]
      ]
      })
    end
  end
end
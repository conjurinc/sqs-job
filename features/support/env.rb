$LOAD_PATH.unshift 'features'

require 'conjur/cli'
require 'sqs/job'
require 'slosilo'

Conjur::Config.load
Conjur::Config.apply
conjur = Conjur::Authn.connect

policy = JSON.parse(File.read('policy.json'))
policy_id = policy['policy']

ENV['AWS_ACCESS_KEY_ID'] = conjur.variable([ policy_id, 'aws/access_key_id' ].join('/')).value
ENV['AWS_SECRET_ACCESS_KEY'] = conjur.variable([ policy_id, 'aws/secret_access_key' ].join('/')).value
  
signing_key_id = SQS::Job::Policy.private_variable_name([ policy_id, 'jobs' ].join('/'))
queue_name = [ policy_id.gsub(/[^a-zA-Z0-9-]/, '-'), 'job-queue' ].join('-')

require 'aws-sdk'
sqs ||= AWS::SQS::new
$queue = sqs.queues.named(queue_name)

SQS::Job.signing_keys = [ Slosilo::Key.new(conjur.variable(signing_key_id).value) ]

$messages_received = []
$worker_thread = nil
  
Before do
  $messages_received.clear
  $worker_thread = Thread.new do
    begin
      SQS::Job::Worker.new($queue).run
    rescue
      $stderr.puts $!
      raise $!
    end
  end
end

After do
  $worker_thread.kill
end

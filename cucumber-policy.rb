$LOAD_PATH.unshift 'lib'
require 'sqs/job'

policy "sqs-job-cucumber-1.0" do
  create_signing_key_variables 'jobs'

  aws_credentials = [ 
    variable("aws/access_key_id"), 
    variable("aws/secret_access_key")
  ]
  
  user "alice" do
    can_submit_job  'jobs', aws_credentials
    can_process_job 'jobs', aws_credentials
  end
end

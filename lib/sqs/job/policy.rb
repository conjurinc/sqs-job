module SQS::Job
  module Policy
    def create_signing_key_variables queue_name
      options = {
        'mime_type' => 'application/x-pem-file'
      }
      public_key =  variable(SQS::Job::Policy.public_variable_name(queue_name),  options).tap do |v|
        v.resource.annotations['kind'] = "RSA public key"
      end
      private_key = variable(SQS::Job::Policy.private_variable_name(queue_name), options).tap do |v|
        v.resource.annotations['kind'] = "RSA private key"
      end
      [ public_key, private_key ].tap do |vars|
        vars.each do |var|
          options.each do |k,v|
            var.resource.annotations[k] = v
          end
          var.resource.annotations['facility'] = 'sqs/job'
        end
      end
    end
    
    def can_submit_job queue_name, aws_credentials
      can "execute", variable(SQS::Job::Policy.public_variable_name(queue_name))
      aws_credentials.each do |var|
        can "execute", var
      end
    end
    
    def can_process_job queue_name, aws_credentials
      can "execute", variable(SQS::Job::Policy.private_variable_name(queue_name))
      aws_credentials.each do |var|
        can "execute", var
      end
    end
    
    class << self
      def public_variable_name queue_name
        [ queue_name, "signing-key/public" ].join('/')
      end
      
      def private_variable_name queue_name
        [ queue_name, "signing-key/private" ].join('/')
      end
    end
  end
end

Conjur::DSL::Runner.module_eval do
  include SQS::Job::Policy
end

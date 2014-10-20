# SQS::Job

Simple job processor which uses SQS.

Here's an interesting description of job processing using SQS, which isn't actually a spec of this code,
but is nicely related:

http://mauricio.github.io/2014/09/01/make-the-most-of-sqs.html

## Installation

Add this line to your application's Gemfile:

    gem 'sqs-job'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install sqs-job

# Cucumber

Populate aws.secrets with `aws_access_key_id` and `aws_secret_access_key`. Then:

    $ conjur policy load -c policy.json cucumber-policy.rb
    $ conjur env run -c aws.secrets -- env POLICY_FILE=policy.json rake provision
    $ cucumber

## Contributing

1. Fork it ( https://github.com/[my-github-username]/sqs-job/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request

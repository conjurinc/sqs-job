When(/^I send a message$/) do
  SQS::Job.send_message $queue, "test_message", {}
  sleep 2
end

Then(/^the message is processed$/) do
  expect($messages_received).to eq([ SQS::Job::Message::TestMessage ])
end
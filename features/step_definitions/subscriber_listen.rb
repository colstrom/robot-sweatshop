require 'ezmq'
require 'timeout'

Given /^I subscribe to the '(.*?)' queue$/ do |queue|
  @subscriber = EZMQ::Subscriber.new address: 'tcp://127.0.0.1:5557'
  @subscriber.subscribe queue
end

Then /^I hear the queue count$/ do
  response = Timeout.timeout(1) { @subscriber.listen }
  expect(response).to_not be_nil
  expect(response.to_i).to be > 0
end

Then /^I hear nothing$/ do
  expect {
    Timeout.timeout(1) { @subscriber.listen }
  }.to raise_error Timeout::Error
end
require 'kintama'
require 'ezmq'
require 'json'
require 'timeout'
require_relative 'shared/process_spawning'
require_relative 'shared/helpers'

describe 'the Payload Parser' do
  include QueueHelper
  include InHelper

  setup do
    @client = EZMQ::Client.new port: configatron.payload_parser_port
  end

  %w(Bitbucket Github JSON Empty).each do |format|
    given "valid #{format} payloads" do
      setup do
        payload = example_payload_request of_format: format
        @response = Timeout.timeout($for_a_moment) do
          @client.request JSON.dump(payload)
        end
      end

      should 'return a parsed payload object' do
        @response = JSON.parse @response
        assert_equal true, @response['error'].empty?
        assert_kind_of Hash, @response['payload']

        keys = case format
        when 'JSON'
          %w(test1 test2)
        when 'Empty'
          []
        else
          Payload.hash_keys
        end
        keys.each do |key|
          payload = @response['payload']
          assert_not_nil payload[key]
          assert_not_equal key, payload[key] # catches "string"[key]
        end
      end
    end
  end

  %w(NonJSON).each do |format|
    given "#{format} payloads" do
      setup do
        payload = example_raw_payload of_format: format
        @response = Timeout.timeout($for_a_moment) do
          @client.request "#{payload}"
        end
      end

      should 'return an error object' do
        @response = JSON.load(@response)
        assert_kind_of String, @response['error']
        assert_equal true, @response['payload'].empty?
      end
    end
  end
end

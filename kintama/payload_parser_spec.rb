require 'kintama'
require 'ezmq'
require 'json'
require_relative 'shared/process_spawning'
require_relative 'shared/helpers'

describe 'the Payload Parser' do
  include QueueHelper
  include InHelper
  include PayloadHelper

  setup do
    @client = EZMQ::Client.new port: 5556
    @raw_queue = 'raw-payload'
    @parsed_queue = 'parsed-payload'
    clear_all_queues
  end

  %w(Bitbucket Github Custom).each do |format|
    given "valid #{format} data in 'raw-payload'" do
      setup do
        payload = example_raw_payload(with_format: format)
        @client.request "#{@raw_queue} #{payload}"
        sleep $for_a_while
      end

      should 'remove it from \'raw-payload\'' do
        response = @client.request @raw_queue
        assert_equal '', response
      end

      should 'enqueue parsed payload data and job name to \'parsed-payload\'' do
        response = @client.request "mirror-#{@parsed_queue}"
        response = JSON.parse response

        assert_kind_of Hash, response['payload']
        keys = Payload.hash_keys
        keys = %w(test1 test2) if format == 'Custom'
        keys.each do |key|
          assert_not_nil response['payload'][key]
          assert_not_equal key, response['payload'][key] # important for how Ruby interprets "string"['key']
        end
        assert_kind_of String, response['job_name']
      end
    end
  end

  given 'invalid payload data in \'raw-payload\'' do
    setup do
      invalid_data = {
        malformed_payload:  example_raw_payload(with_format: 'malformed'),
        unsupported_format: example_raw_payload(with_format: 'asdf'),
        not_json:           'not_json'
      }
      invalid_data.each do |_type, datum|
        @client.request "#{@raw_queue} #{datum}"
      end
      sleep $for_a_while
      # TODO: should not crash the payload parser
    end

    should 'remove all of it from \'raw-payload\'' do
      response = @client.request @raw_queue
      assert_equal '', response
    end

    should 'not queue anything to \'parsed-payload\'' do
      response = @client.request @parsed_queue
      assert_equal '', response
    end
  end
end

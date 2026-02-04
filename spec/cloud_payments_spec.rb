# frozen_string_literal: true
require 'spec_helper'

describe CloudPayments do
  describe '#config=' do
    specify{ expect{ CloudPayments.config = 'config' }.to change{ CloudPayments.config }.to('config') }
  end

  it 'supports global configuration' do
    CloudPayments.config.secret_key = "OLD_KEY"

    CloudPayments.configure do |c|
      c.secret_key = "NEW_KEY"
    end

    expect(CloudPayments.config.secret_key).to eq "NEW_KEY"
    expect(CloudPayments.client.config.secret_key).to eq "NEW_KEY"
  end

  it 'supports local configuration' do
    CloudPayments.config.secret_key = "OLD_KEY"

    config = CloudPayments::Config.new do |c|
      c.secret_key = "NEW_KEY"
    end
    client = CloudPayments::Client.new(config)
    webhooks = CloudPayments::Webhooks.new(config)

    expect(CloudPayments.config.secret_key).to eq "OLD_KEY"
    expect(config.secret_key).to eq "NEW_KEY"
    expect(client.config.secret_key).to eq "NEW_KEY"
    expect(webhooks.config.secret_key).to eq "NEW_KEY"
  end

  describe '.with_request_id' do
    it 'sets current_request_id within the block' do
      expect(CloudPayments.current_request_id).to be_nil

      CloudPayments.with_request_id('test-request-123') do
        expect(CloudPayments.current_request_id).to eq('test-request-123')
      end

      expect(CloudPayments.current_request_id).to be_nil
    end

    it 'restores previous request_id after block' do
      CloudPayments.with_request_id('outer-request') do
        expect(CloudPayments.current_request_id).to eq('outer-request')

        CloudPayments.with_request_id('inner-request') do
          expect(CloudPayments.current_request_id).to eq('inner-request')
        end

        expect(CloudPayments.current_request_id).to eq('outer-request')
      end
    end

    it 'restores previous request_id even when exception is raised' do
      CloudPayments.with_request_id('outer-request') do
        begin
          CloudPayments.with_request_id('inner-request') do
            raise 'test error'
          end
        rescue RuntimeError
        end

        expect(CloudPayments.current_request_id).to eq('outer-request')
      end
    end

    it 'returns the block result' do
      result = CloudPayments.with_request_id('test-request') do
        'block result'
      end

      expect(result).to eq('block result')
    end
  end

  describe '.current_request_id' do
    it 'returns nil when no request_id is set' do
      expect(CloudPayments.current_request_id).to be_nil
    end
  end
end

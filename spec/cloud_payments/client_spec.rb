# frozen_string_literal: true
require 'spec_helper'

describe CloudPayments::Client do
  describe '#headers' do
    let(:client) { CloudPayments::Client.new }

    it 'includes Content-Type header' do
      expect(client.send(:headers)).to include('Content-Type' => 'application/json')
    end

    it 'does not include X-Request-ID when not set' do
      expect(client.send(:headers)).not_to have_key('X-Request-ID')
    end

    it 'includes X-Request-ID when set via with_request_id' do
      CloudPayments.with_request_id('test-idempotency-key') do
        expect(client.send(:headers)).to include('X-Request-ID' => 'test-idempotency-key')
      end
    end
  end

  describe 'X-Request-ID header in requests' do
    let(:request_id) { 'charge:invoice-12345' }

    before do
      stub_request(:post, 'http://localhost:9292/payments/tokens/charge')
        .with(
          headers: {
            'Content-Type' => 'application/json',
            'X-Request-ID' => request_id
          },
          basic_auth: ['user', 'pass']
        )
        .to_return(
          status: 200,
          body: '{"Success":true,"Model":{"TransactionId":12345,"Status":"Completed"}}',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'sends X-Request-ID header with the request' do
      CloudPayments.with_request_id(request_id) do
        response = CloudPayments.client.perform_request('/payments/tokens/charge', { amount: 100 })
        expect(response.status).to eq(200)
      end
    end
  end

  describe 'request without X-Request-ID' do
    before do
      stub_request(:post, 'http://localhost:9292/payments/tokens/charge')
        .with(
          headers: { 'Content-Type' => 'application/json' },
          basic_auth: ['user', 'pass']
        )
        .to_return(
          status: 200,
          body: '{"Success":true,"Model":{"TransactionId":12345,"Status":"Completed"}}',
          headers: { 'Content-Type' => 'application/json' }
        )
    end

    it 'does not send X-Request-ID header when not set' do
      response = CloudPayments.client.perform_request('/payments/tokens/charge', { amount: 100 })
      expect(response.status).to eq(200)
    end
  end
end

# frozen_string_literal: true
require 'spec_helper'

describe CloudPayments::Client do
  describe '#headers' do
    let(:client) { CloudPayments::Client.new }

    it 'includes Content-Type header' do
      expect(client.send(:headers)).to include('Content-Type' => 'application/json')
    end

    it 'does not include X-Request-ID when not provided' do
      expect(client.send(:headers)).not_to have_key('X-Request-ID')
    end

    it 'does not include X-Request-ID when nil' do
      expect(client.send(:headers, request_id: nil)).not_to have_key('X-Request-ID')
    end

    it 'does not include X-Request-ID when empty string' do
      expect(client.send(:headers, request_id: '')).not_to have_key('X-Request-ID')
    end

    it 'does not include X-Request-ID when whitespace only' do
      expect(client.send(:headers, request_id: '   ')).not_to have_key('X-Request-ID')
    end

    it 'strips whitespace from request_id' do
      expect(client.send(:headers, request_id: '  my-key  ')).to include('X-Request-ID' => 'my-key')
    end

    it 'includes X-Request-ID when provided' do
      expect(client.send(:headers, request_id: 'test-idempotency-key')).to include('X-Request-ID' => 'test-idempotency-key')
    end
  end

  describe '#perform_request with request_id' do
    let(:request_id) { 'charge:invoice-12345' }

    it 'sends X-Request-ID header with the request' do
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

      response = CloudPayments.client.perform_request('/payments/tokens/charge', { amount: 100 }, request_id: request_id)
      expect(response.status).to eq(200)
    end

    it 'does not send X-Request-ID header when not provided' do
      request_headers = nil
      stub_request(:post, 'http://localhost:9292/payments/tokens/charge')
        .with { |request| request_headers = request.headers; true }
        .to_return(
          status: 200,
          body: '{"Success":true,"Model":{"TransactionId":12345,"Status":"Completed"}}',
          headers: { 'Content-Type' => 'application/json' }
        )

      CloudPayments.client.perform_request('/payments/tokens/charge', { amount: 100 })
      expect(request_headers).not_to have_key('X-Request-Id')
    end
  end
end

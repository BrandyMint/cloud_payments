# frozen_string_literal: true
require 'date'
require 'hashie'
require 'faraday'
require 'multi_json'
require 'cloud_payments/version'
require 'cloud_payments/config'
require 'cloud_payments/namespaces'
require 'cloud_payments/models'
require 'cloud_payments/client'
require 'cloud_payments/webhooks'

module CloudPayments
  extend self

  CURRENT_REQUEST_ID_KEY = :cloud_payments_request_id

  def with_request_id(request_id)
    previous = Thread.current[CURRENT_REQUEST_ID_KEY]
    Thread.current[CURRENT_REQUEST_ID_KEY] = request_id
    yield
  ensure
    Thread.current[CURRENT_REQUEST_ID_KEY] = previous
  end

  def current_request_id
    Thread.current[CURRENT_REQUEST_ID_KEY]
  end

  def config=(value)
    @config = value
  end

  def config
    @config ||= Config.new
  end

  def configure
    yield config
  end

  def client=(value)
    @client = value
  end

  def client
    @client ||= Client.new
  end

  def webhooks
    @webhooks ||= Webhooks.new
  end
end

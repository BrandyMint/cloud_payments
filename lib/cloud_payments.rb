require 'date'
require 'hashie'
require 'faraday'
require 'multi_json'
require 'pp'
require 'cloud_payments/version'
require 'cloud_payments/config'
require 'cloud_payments/namespaces'
require 'cloud_payments/models'
require 'cloud_payments/client'

module CloudPayments
  extend self

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
end

CloudPayments.configure do |c|
  c.host = 'http://localhost:9292'
  c.log = true
end
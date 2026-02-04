# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)

require 'bundler'
Bundler.require(:default, :test)

require 'webmock/rspec'

WebMock.enable!
WebMock.disable_net_connect!

Dir["./spec/support/**/*.rb"].each { |f| require f }

RSpec.configure do |config|
  config.mock_with :rspec
  config.include CloudPayments::RSpec::Helpers

  # these params are used in stubs, in basic auth
  # see webmock_stub in spec/support/helpers.rb
  def default_config
    CloudPayments::Config.new do |c|
      c.public_key = 'user'
      c.secret_key = 'pass'
      c.host = 'http://localhost:9292'
      c.log = false
      # c.raise_banking_errors = true
    end
  end

  CloudPayments.config = default_config

  config.after :each do
    CloudPayments.config = default_config
    CloudPayments.client = CloudPayments::Client.new
    Thread.current[CloudPayments::CURRENT_REQUEST_ID_KEY] = nil
  end
end

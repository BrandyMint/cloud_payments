# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Base
      attr_reader :client, :parent_path

      class << self
        def resource_name
          self.name.split('::').last.downcase
        end
      end

      def initialize(client, parent_path = nil)
        @client = client
        @parent_path = parent_path
      end

      def request(path, params = {}, request_id: nil)
        response = client.perform_request(resource_path(path), params, request_id: request_id)
        raise_gateway_error(response.body) unless response.body[:success]
        response.body
      end

      protected

      def api_exceptions
        [::Faraday::ConnectionFailed, ::Faraday::TimeoutError, Client::ServerError, Client::GatewayError]
      end

      def resource_path(path = nil)
        [parent_path, self.class.resource_name, path].flatten.compact.join(?/).squeeze(?/)
      end

      def raise_gateway_error(body)
        raise_reasoned_gateway_error(body) || raise_raw_gateway_error(body)
      end

      def raise_reasoned_gateway_error(body)
        return unless reason_present?(body)

        error_class = Client::GATEWAY_ERRORS[body.dig(:model, :reason_code)] || Client::ReasonedGatewayError
        fail error_class, reasoned_error_message(body)
      end

      def raise_raw_gateway_error(body)
        fail Client::GatewayError.new(body[:message], body) if !body[:message].nil? && !body[:message].empty?
      end

      def reason_present?(body)
        !body[:model].nil? &&
          !body[:model].empty? &&
          !body[:model][:reason_code].nil? &&
          CloudPayments.config.raise_banking_errors
      end

      def reasoned_error_message(body)
        message = body[:message]
        return message unless message.nil? || message.empty?

        card_holder_message = body.dig(:model, :card_holder_message)
        return card_holder_message unless card_holder_message.nil? || card_holder_message.empty?

        "CloudPayments gateway error (reason_code=#{body.dig(:model, :reason_code).inspect})"
      end
    end
  end
end

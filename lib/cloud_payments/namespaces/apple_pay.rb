# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class ApplePay < Base
      ValidationUrlMissing = Class.new(StandardError)

      def self.resource_name
        'applepay'
      end

      def start_session(attributes, request_id: nil)
        validation_url = attributes.fetch(:validation_url) { raise ValidationUrlMissing.new('validation_url is required') }

        request(:startsession, { "ValidationUrl" => validation_url }, request_id: request_id)
      end
    end
  end
end

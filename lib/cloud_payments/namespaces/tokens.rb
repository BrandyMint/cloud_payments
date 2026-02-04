# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Tokens < Base
      def charge(attributes, request_id: nil)
        response = request(:charge, attributes, request_id: request_id)
        Transaction.new(response[:model])
      end

      def auth(attributes, request_id: nil)
        response = request(:auth, attributes, request_id: request_id)
        Transaction.new(response[:model])
      end
    end
  end
end

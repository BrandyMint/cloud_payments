# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Cards < Base
      def charge(attributes, request_id: nil)
        response = request(:charge, attributes, request_id: request_id)
        instantiate(response[:model])
      end

      def auth(attributes, request_id: nil)
        response = request(:auth, attributes, request_id: request_id)
        instantiate(response[:model])
      end

      def post3ds(attributes, request_id: nil)
        response = request(:post3ds, attributes, request_id: request_id)
        instantiate(response[:model])
      end

      private

      def instantiate(model)
        if model[:pa_req]
          Secure3D.new(model)
        else
          Transaction.new(model)
        end
      end
    end
  end
end

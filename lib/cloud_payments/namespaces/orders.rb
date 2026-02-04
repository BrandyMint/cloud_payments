# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Orders < Base
      def create(attributes, request_id: nil)
        response = request(:create, attributes, request_id: request_id)
        Order.new(response[:model])
      end

      def cancel(order_id, request_id: nil)
        request(:cancel, { id: order_id }, request_id: request_id)[:success]
      end
    end
  end
end

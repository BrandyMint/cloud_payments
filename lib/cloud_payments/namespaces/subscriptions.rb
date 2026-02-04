# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Subscriptions < Base
      def find(id)
        response = request(:get, { id: id })
        Subscription.new(response[:model])
      end

      def find_all(account_id)
        response = request(:find, { account_id: account_id })
        Array(response[:model]).map { |item| Subscription.new(item) }
      end

      def create(attributes, request_id: nil)
        response = request(:create, attributes, request_id: request_id)
        Subscription.new(response[:model])
      end

      def update(id, attributes, request_id: nil)
        response = request(:update, attributes.merge(id: id), request_id: request_id)
        Subscription.new(response[:model])
      end

      def cancel(id, request_id: nil)
        request(:cancel, { id: id }, request_id: request_id)[:success]
      end
    end
  end
end

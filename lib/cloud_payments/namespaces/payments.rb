# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Payments < Base
      def cards
        Cards.new(client, resource_path)
      end

      def tokens
        Tokens.new(client, resource_path)
      end

      def confirm(id, amount, request_id: nil)
        request(:confirm, { transaction_id: id, amount: amount }, request_id: request_id)[:success]
      end

      def void(id, request_id: nil)
        request(:void, { transaction_id: id }, request_id: request_id)[:success]
      end

      def cancel(id, request_id: nil)
        void(id, request_id: request_id)
      end

      def refund(id, amount, request_id: nil)
        request(:refund, { transaction_id: id, amount: amount }, request_id: request_id)[:success]
      end

      def post3ds(id, pa_res, request_id: nil)
        response = request(:post3ds, { transaction_id: id, pa_res: pa_res }, request_id: request_id)
        Transaction.new(response[:model])
      end

      def get(id)
        response = request(:get, { transaction_id: id })
        Transaction.new(response[:model])
      end

      def find(invoice_id)
        response = request(:find, { invoice_id: invoice_id })
        Transaction.new(response[:model])
      end
    end
  end
end

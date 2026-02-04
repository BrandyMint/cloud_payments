# frozen_string_literal: true
module CloudPayments
  module Namespaces
    class Kassa < Base
      KeyNotProvided             = Class.new(StandardError)
      InnNotProvided             = Class.new(KeyNotProvided)
      TypeNotProvided            = Class.new(KeyNotProvided)
      CustomerReceiptNotProvided = Class.new(KeyNotProvided)

      CORRECTION_RECEIPT_REQUIRED_ATTRIBUTES = %i[organization_inn taxation_system correction_receipt_type cause_correction amounts]

      def self.resource_name
        'kkt'
      end

      def receipt(attributes)
        attributes.fetch(:inn)  { raise InnNotProvided.new('inn attribute is required') }
        attributes.fetch(:type) { raise TypeNotProvided.new('type attribute is required') }
        attributes.fetch(:customer_receipt)  { raise CustomerReceiptNotProvided.new('customer_receipt is required') }

        request(:receipt, attributes)
      end

      def correction_receipt(attributes)
        missing_attributes = CORRECTION_RECEIPT_REQUIRED_ATTRIBUTES.select do |attr|
          !attributes.key?(attr)
        end
        raise KeyNotProvided.new("Attribute(s) #{missing_attributes.join(',')} are required") if missing_attributes.any?

        request('correction-receipt', correction_receipt_data: attributes)
      end

      # Запрос статуса чека коррекции
      def correction_receipt_status(id)
        request('correction-receipt/status/get', id: id)
      end

      # Получение данных чека коррекции
      def correction_receipt_info(id)
        request('correction-receipt/get', id: id)
      end
    end
  end
end

module Fabric
  class AttachPaymentMethodOperation
    include Fabric

    def initialize(payment_method_id, customer, update_default: false)
      @log_data = {
        class: self.class.name, payment_method_id: payment_method_id,
        customer: customer
      }
      flogger.json_info 'Started', @log_data

      @payment_method_id = payment_method_id
      @customer = get_document(Customer, customer)
      @update_default = update_default
    end

    def call
      stripe_payment_method = Stripe::PaymentMethod.attach(
        @payment_method_id,
        customer: @customer.stripe_id,
      )

      payment_method = PaymentMethod.find_or_create_by(
        stripe_id: @payment_method_id
      )
      payment_method.sync_with stripe_payment_method
      saved = payment_method.save

      if @update_default
        UpdateCustomerOperation.new(
          @customer,
          invoice_settings: { default_payment_method: @payment_method_id }
        ).call
        flogger.json_info 'Updated Default', @log_data
      end

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [payment_method, stripe_payment_method]
    end

  end
end

module Fabric
  class AttachPaymentMethodOperation
    include Fabric

    def initialize(payment_method_id, customer_id)
      @log_data = {
        class: self.class.name, payment_method_id: payment_method_id,
        customer_id: customer_id
      }
      flogger.json_info 'Started', @log_data

      @payment_method_id = payment_method_id
      @customer_id = customer_id
    end

    def call
      stripe_payment_method = Stripe::PaymentMethod.attach(
        @payment_method_id,
        customer: @customer_id,
      )

      payment_method = Fabric::PaymentMethod.find_or_create_by(
        stripe_id: @payment_method_id
      )
      payment_method.sync_with stripe_payment_method
      saved = payment_method.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [payment_method, stripe_payment_method]
    end

  end
end

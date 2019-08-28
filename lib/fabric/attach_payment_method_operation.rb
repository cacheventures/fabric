module Fabric
  class AttachPaymentMethodOperation
    include Fabric

    def initialize(payment_method, customer)
      @log_data = {
        class: self.class.name, payment_method: payment_method,
        customer: customer
      }
      flogger.json_info 'Started', @log_data

      @payment_method = get_document(Fabric::PaymentMethod, payment_method)
      @customer = get_document(Fabric::Customer, customer)
    end

    def call
      stripe_payment_method = Stripe::PaymentMethod.attach(
        @payment_method.stripe_id,
        customer: @customer.stripe_id,
      )
      @payment_method.sync_with stripe_payment_method
      saved = @payment_method.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@payment_method, stripe_payment_method]
    end

  end
end

module Fabric
  class UpdatePaymentMethodOperation
    include Fabric

    def initialize(payment_method, attributes)
      @log_data = {
        class: self.class.name, payment_method: payment_method,
        attributes: attributes
      }
      flogger.json_info 'Started', @log_data

      @payment_method = get_document(Fabric::PaymentMethod, payment_method)
      @attributes = attributes
    end

    def call
      stripe_payment_method = Stripe::PaymentMethod.update(
        @payment_method.stripe_id,
        @attributes
      )

      @payment_method.sync_with stripe_payment_method
      saved = @payment_method.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@payment_method, stripe_payment_method]
    end

  end
end

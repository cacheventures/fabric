module Fabric
  class DetachPaymentMethodOperation
    include Fabric

    def initialize(payment_method)
      @log_data = { class: self.class.name, payment_method: payment_method }
      flogger.json_info 'Started', @log_data

      @payment_method = get_document(PaymentMethod, payment_method)
    end

    def call
      stripe_detach = Stripe::PaymentMethod.detach(@payment_method.stripe_id)
      destroyed = @payment_method.destroy

      flogger.json_info 'Completed', @log_data.merge(
        stripe_detach: stripe_detach, destroyed: destroyed
      )
    end

  end
end

module Fabric
  class DetachPaymentMethodOperation
    include Fabric

    def initialize(payment_method_id)
      @log_data = { class: self.class.name, payment_method_id: payment_method_id }
      flogger.json_info 'Started', @log_data

      @payment_method_id = payment_method_id
      @payment_method = Fabric::PaymentMethod.find_by(
        stripe_id: payment_method_id
      )
    end

    def call
      stripe_detach = Stripe::PaymentMethod.detach(@payment_method_id)
      destroyed = @payment_method ? @payment_method.destroy : false

      flogger.json_info 'Completed', @log_data.merge(
        stripe_detach: stripe_detach, destroyed: destroyed
      )
    end

  end
end

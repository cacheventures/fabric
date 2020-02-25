module Fabric
  class UpdatePaymentIntentOperation
    include Fabric

    def initialize(payment_intent, attributes = {})
      @log_data = {
        class: self.class.name, payment_intent: payment_intent,
        attributes: attributes
      }
      Fabric.config.logger.json_info 'started', @log_data

      @payment_intent = get_document(Fabric::PaymentIntent, payment_intent)
      @attributes = attributes
    end

    def call
      stripe_pi = Stripe::PaymentIntent.update(
        @payment_intent.stripe_id,
        @attributes
      )
      @payment_intent.sync_with(stripe_pi)
      saved = @payment_intent.save
      Fabric.config.logger.json_info 'completed', saved: saved
      @payment_intent
    end

  end
end

module Fabric
  class CreatePaymentIntentOperation
    include Fabric

    def initialize(customer, attributes = {})
      @log_data = {
        class: self.class.name, customer: customer, attributes: attributes
      }
      Fabric.config.logger.json_info 'started', @log_data
      @customer = get_document(Fabric::Customer, customer) if customer
      @attributes = attributes
    end

    def call
      stripe_pi = Stripe::PaymentIntent.create(@attributes)
      pi = @customer ? @customer.payment_intents.build : PaymentIntent.new
      pi.sync_with(stripe_pi)
      saved = pi.save
      Fabric.config.logger.json_info 'completed', saved: saved
      pi
    end

  end
end

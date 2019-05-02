module Fabric
  class UpdateCardOperation
    include Fabric

    def initialize(card, attributes)
      Fabric.config.logger.info "UpdateCardOperation: Started with "\
        "#{card} #{attributes}"
      @card = get_document(Fabric::Card, card)
      @customer = @card.customer
      @attributes = attributes
    end

    def call
      stripe_customer = Stripe::Customer.retrieve(@customer.stripe_id)
      stripe_card = stripe_customer.sources.retrieve(@card.stripe_id)
      @attributes.each { |k, v| stripe_card.send("#{k}=", v) }
      stripe_card.save

      @card.sync_with(stripe_card)
      card_saved = @card.save
      Fabric.config.logger.info "UpdateCardOperation: Completed. saved: "\
        "#{card_saved}"
    end
  end
end

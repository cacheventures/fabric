module Fabric
  class CreateCardOperation
    include Fabric

    def initialize(customer, token_or_card)
      Fabric.config.logger.info "CreateCardOperation: Started with "\
        "#{customer} #{token_or_card}"
      @customer = get_document(Fabric::Customer, customer)
      @card = token_or_card
    end

    def call
      stripe_customer = Stripe::Customer.retrieve @customer.stripe_id

      stripe_card = stripe_customer.sources.create(card: @card)

      stripe_customer.refresh
      unless stripe_customer.default_source == stripe_card.id
        stripe_customer.default_source = stripe_card.id
        stripe_customer.save
      end

      card = Fabric::Card.new(customer: @customer)
      card.sync_with(stripe_card)
      card_saved = card.save

      @customer.sync_with(stripe_customer)

      customer_saved = @customer.save
      Fabric.config.logger.info "CreateCardOperation: Completed. card saved: "\
        "#{card_saved} customer saved: #{customer_saved}"
      card
    end
  end
end

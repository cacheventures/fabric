module Fabric
  class UpdateCardOperation
    include Fabric

    def initialize(card, attributes)
      @log_data = { class: self.class.name, card: card, attributes: attributes }
      flogger.json_info 'Started', @log_data

      @card = get_document(Card, card)
      @attributes = attributes
    end

    def call
      stripe_card = Stripe::Issuing::Card.update(@card.stripe_id, @attributes)
      @card.sync_with(stripe_card)
      saved = @card.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@card, stripe_card]
    end
  end
end

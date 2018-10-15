module Fabric
  module Webhooks
    class SourceUpdated
      include Fabric::Webhook

      def call(event)
        stripe_card = event.try(:data).try(:object)
        unless stripe_card.try(:object) == 'card'
          Fabric.config.logger.info 'SourceUpdated: Not a card object'
          return
        end

        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:source)

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:customer)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
        end
        unless customer.present?
          Fabric.config.logger.info "SourceUpdated: Unable to locate "\
            "customer: #{customer_id}"
          return
        end

        stripe_card = event.data.object
        card_id = stripe_card.try(:id)
        card = Fabric::Card.find_by(stripe_id: card_id)
        unless card.present?
          Fabric.config.logger.info "SourceUpdated: No such card: #{card_id}"
          return
        end

        card.sync_with stripe_card
        saved = card.save
        Fabric.config.logger.info "SourceUpdated: Updated card: "\
          "#{stripe_card.id} saved: #{saved}"
      end

    end
  end
end

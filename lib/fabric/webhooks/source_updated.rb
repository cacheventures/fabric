module Fabric
  module Webhooks
    class SourceUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events

        stripe_card = event.data.object
        unless stripe_card.object == 'card'
          Fabric.config.logger.info 'SourceUpdated: Not a card object'
          return
        end

        persist_model(event) if Fabric.config.persist?(:source)
        handle(event)
      end

      def persist_model(event)
        stripe_card = event.data.object
        card = retrieve_local(:card, stripe_card.id)
        return unless card
        return unless most_recent_update?(card, event)

        card.sync_with stripe_card
        saved = card.save
        Fabric.config.logger.info "SourceUpdated: Updated card: "\
          "#{card.stripe_id} saved: #{saved}"
      end

    end
  end
end

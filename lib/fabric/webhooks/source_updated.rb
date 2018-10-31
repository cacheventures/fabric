module Fabric
  module Webhooks
    class SourceUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events

        unless event['data']['object']['object'] == 'card'
          Fabric.config.logger.info 'SourceUpdated: Not a card object'
          return
        end

        stripe_source = Stripe::Customer.retrieve(
          event['data']['object']['customer']
        ).sources.retrieve(event['data']['object']['id'])
        handle(event, stripe_source)
        persist_model(stripe_source) if Fabric.config.persist?(:source)
      end

      def persist_model(stripe_source)
        card = retrieve_local(:card, stripe_source.id)
        return unless card
        card.sync_with(stripe_source)
        saved = card.save
        Fabric.config.logger.info "SourceUpdated: Updated card: "\
          "#{card.stripe_id} saved: #{saved}"
      end
    end
  end
end

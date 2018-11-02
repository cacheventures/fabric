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

        stripe_customer = retrieve_resource(
          'customer', event['data']['object']['customer']
        )
        return if stripe_customer.nil?

        begin
          stripe_source = stripe_customer.sources.retrieve(
            event['data']['object']['id']
          )
        rescue Stripe::InvalidRequestError => e
          log_data = {
            customer: stripe_customer.id, source: event['data']['object']['id'],
            error: e.inspect
          }
          Fabric.config.logger.info("SourceCreated: couldn't retrieve source"\
            " #{log_data.to_json}")
          return
        end
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

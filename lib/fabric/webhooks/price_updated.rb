module Fabric
  module Webhooks
    class PriceUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_price = retrieve_resource(
          'price', { id: event['data']['object']['id'], expand: ['tiers'] }
        )
        return if stripe_price.nil?

        handle(event, stripe_price)
        persist_model(stripe_price) if Fabric.config.persist?(:price)
      end

      def persist_model(stripe_price)
        price = retrieve_local(:price, stripe_price.id)
        return unless price

        stripe_price = Stripe::Price.retrieve(
          id: stripe_price.id,
          expand: ['tiers']
        )
        price.sync_with(stripe_price)
        saved = price.save
        Fabric.config.logger.json_info 'updated price',
          class: self.class.to_s, price: price.stripe_id, saved: saved
      end

    end
  end
end

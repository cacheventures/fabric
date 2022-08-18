module Fabric
  module Webhooks
    class PriceCreated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_price = retrieve_resource(
          'price', event['data']['object']['id']
        )
        return if stripe_price.nil?

        handle(event, stripe_price)
        persist_model(stripe_price) if Fabric.config.persist?(:price)
      end

      def persist_model(stripe_price)
        price = Fabric::Price.new
        stripe_price = Stripe::Price.retrieve(
          id: stripe_price.id,
          expand: price.expand_attributes
        )
        price.sync_with(stripe_price)
        saved = price.save
        Fabric.config.logger.json_info 'created price',
          class: self.class.to_s, price: price.stripe_id, saved: saved
      end

    end
  end
end

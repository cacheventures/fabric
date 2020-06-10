module Fabric
  module Webhooks
    class PriceDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:price)
      end

      def persist_model(event)
        price = retrieve_local(:price, event['data']['object']['id'])
        return unless price

        price.destroy
        Fabric.config.logger.json_info 'destroyed price',
          class: self.class.to_s, price: price.stripe_id
      end

    end
  end
end

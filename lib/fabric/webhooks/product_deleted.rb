module Fabric
  module Webhooks
    class ProductDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:product)
      end

      def persist_model(event)
        product = retrieve_local(:product, event['data']['object']['id'])
        return unless product

        product.destroy
        Fabric.config.logger.json_info 'destroyed product',
          class: self.class.to_s, product: product.stripe_id
      end

    end
  end
end

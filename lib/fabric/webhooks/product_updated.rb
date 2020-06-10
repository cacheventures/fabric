module Fabric
  module Webhooks
    class ProductUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_product = retrieve_resource(
          'product', event['data']['object']['id']
        )
        return if stripe_product.nil?

        handle(event, stripe_product)
        persist_model(stripe_product) if Fabric.config.persist?(:product)
      end

      def persist_model(stripe_product)
        product = retrieve_local(:product, stripe_product.id)
        return unless product

        product.sync_with(stripe_product)
        saved = product.save
        Fabric.config.logger.json_info 'updated product',
          class: self.class.to_s, product: product.stripe_id, saved: saved
      end

    end
  end
end

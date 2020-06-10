module Fabric
  module Webhooks
    class ProductCreated
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
        product = Fabric::Product.new
        product.sync_with(stripe_product)
        saved = product.save
        Fabric.config.logger.json_info 'created product',
          class: self.class.to_s, product: product.stripe_id, saved: saved
      end

    end
  end
end

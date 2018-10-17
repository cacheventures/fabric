module Fabric
  module Webhooks
    class DiscountCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:discount)
        handle(event)
      end

      def persist_model(event)
        stripe_discount = event.data.object
        customer = retrieve_local(:customer, stripe_discount.customer)
        subscription = retrieve_local(
          :subscription, stripe_discount.subscription
        ) if stripe_discount.subscription
        return unless customer

        parent = subscription.present ? subscription : customer
        parent.discount = stripe_discount.to_hash
        parent.save

        saved = discount.save
        Fabric.config.logger.info "DiscountCreated: Created discount on "\
          "parent: #{parent.stripe_id} saved: #{saved}"
      end

    end
  end
end

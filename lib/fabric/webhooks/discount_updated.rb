module Fabric
  module Webhooks
    class DiscountUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_customer = retrieve_resource(
          'customer', event['data']['object']['customer']
        )
        return if stripe_customer.nil?
        stripe_subscription = retrieve_resource(
          'subscription', event['data']['object']['subscription']
        ) if event['data']['object']['subscription']

        handle(event)
        if Fabric.config.persist?(:discount)
          persist_model(stripe_customer, stripe_subscription)
        end
      end

      def persist_model(stripe_customer, stripe_subscription)
        customer = retrieve_local(:customer, stripe_customer.id)
        subscription = retrieve_local(
          :subscription, stripe_subscription.id
        ) if stripe_subscription
        return unless customer

        parent = subscription.present? ? subscription : customer
        stripe_parent = if stripe_subscription.present?
                          stripe_subscription
                        else
                          stripe_customer
                        end
        parent.discount = stripe_parent.discount.try(:to_hash)
        saved = parent.save

        Fabric.config.logger.info "DiscountUpdated: Updated discount on "\
          "parent: #{parent.stripe_id} saved: #{saved}"
      end

    end
  end
end

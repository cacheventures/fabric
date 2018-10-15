module Fabric
  module Webhooks
    class SubscriptionCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:subscription)

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:customer)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
          unless customer.present?
            Fabric.config.logger.info 'SubscriptionCreated: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'SubscriptionCreated: ERROR: No customer.'
          return
        end

        subscription = Fabric::Subscription.new(customer: customer)
        subscription.sync_with(event.data.object)
        saved = subscription.save
        Fabric.config.logger.info "SubscriptionCreated: Created subscription: "\
          "#{subscription.stripe_id} saved: #{saved}"
      end

    end
  end
end

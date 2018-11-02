module Fabric
  module Webhooks
    class CustomerUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_customer = retrieve_resource(
          'customer', event['data']['object']['id']
        )
        return if stripe_customer.nil?

        handle(event, stripe_customer)
        if Fabric.config.persist?(:customer)
          persist_model(stripe_customer)
        end
      end

      def persist_model(stripe_customer)
        customer = retrieve_local(:customer, stripe_customer.id)
        return unless customer

        customer.sync_with(stripe_customer)
        saved = customer.save
        Fabric.config.logger.info "CustomerUpdated: Updated customer: "\
          "#{customer.stripe_id} saved: #{saved}"
      end

    end
  end
end

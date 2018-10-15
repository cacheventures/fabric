module Fabric
  module Webhooks
    class CustomerUpdated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:customer)

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:id)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
        end

        stripe_customer = event.data.object
        if customer.present?
          customer.sync_with(stripe_customer)
          saved = customer.save
          Fabric.config.logger.info "CustomerUpdated: Updated customer: "\
            "#{stripe_customer.id} saved: #{saved}"
        else
          Fabric.config.logger.info "CustomerUpdated: Unable to locate "\
            "customer. customer: #{stripe_customer.id}"
        end
      end

    end
  end
end

module Fabric
  module Webhooks
    class CustomerCreated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_customer = retrieve_resource(
          'customer', event['data']['object']['id']
        )
        return if stripe_customer.nil?

        handle(event, stripe_customer)
        persist_model(stripe_customer) if Fabric.config.persist?(:customer)
      end

      def persist_model(stripe_customer)
        customer = Fabric::Customer.new
        customer.sync_with(stripe_customer)
        saved = customer.save
        Fabric.config.logger.json_info 'created customer',
          class: self.class.to_s, customer: customer.stripe_id, saved: saved
      end

    end
  end
end

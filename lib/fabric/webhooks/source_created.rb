module Fabric
  module Webhooks
    class SourceCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_source = Stripe::Customer.retrieve(
          event['data']['object']['customer']
        ).sources.retrieve(event['data']['object']['id'])
        handle(event, stripe_source)
        persist_model(stripe_source) if Fabric.config.persist?(:source)
      end

      def persist_model(stripe_source)
        customer = retrieve_local(:customer, stripe_source.customer)
        return unless customer

        source = Fabric::Card.new(customer: customer)
        source.sync_with(stripe_source)
        saved = source.save
        Fabric.config.logger.info "SourceCreated: Created source: "\
          "#{source.stripe_id} saved: #{saved}"
      end

    end
  end
end

module Fabric
  module Webhooks
    class SourceCreated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_customer = retrieve_resource(
          'customer', event['data']['object']['customer']
        )
        return if stripe_customer.nil?

        begin
          stripe_source = stripe_customer.sources.retrieve(
            event['data']['object']['id']
          )
        rescue Stripe::InvalidRequestError => e
          log_data = {
            customer: stripe_customer.id, source: event['data']['object']['id'],
            error: e.inspect
          }
          Fabric.config.logger.info("SourceCreated: couldn't retrieve source"\
            " #{log_data.to_json}")
          return
        end
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

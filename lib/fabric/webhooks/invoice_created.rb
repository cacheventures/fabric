module Fabric
  module Webhooks
    class InvoiceCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_invoice = retrieve_resource(
          'invoice', event['data']['object']['id']
        )
        return if stripe_invoice.nil?

        handle(event, stripe_invoice)
        persist_model(stripe_invoice) if Fabric.config.persist?(:invoice)
      end

      def persist_model(stripe_invoice)
        customer = retrieve_local(:customer, stripe_invoice.customer)
        return unless customer

        invoice = Fabric::Invoice.new(customer: customer)
        invoice.sync_with(stripe_invoice)
        saved = invoice.save
        Fabric.config.logger.info "InvoiceCreated: Created invoice: "\
          "#{invoice.stripe_id} saved: #{saved}"
      end
    end
  end
end

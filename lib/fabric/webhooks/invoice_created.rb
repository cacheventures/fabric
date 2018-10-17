module Fabric
  module Webhooks
    class InvoiceCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:invoice)
        handle(event)
      end

      def persist_model(event)
        stripe_invoice = event.data.object
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

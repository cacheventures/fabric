module Fabric
  module Webhooks
    class InvoiceUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:invoice)
        handle(event)
      end

      def persist_model(event)
        stripe_invoice = event.data.object
        invoice = retrieve_local(:invoice, stripe_invoice.id)
        return unless invoice
        return unless most_recent_update?(invoice, event)

        invoice.sync_with(stripe_invoice)
        saved = invoice.save
        Fabric.config.logger.info "InvoiceUpdated: Updated invoice: "\
          "#{invoice.stripe_id} saved: #{saved}"
      end

    end
  end
end

module Fabric
  module Webhooks
    class InvoiceUpdated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:invoice)

        handle(event)
      end

      def persist_model(event)
        stripe_invoice = event.data.object
        invoice = Fabric::Invoice.find_by(
          stripe_id: stripe_invoice.id
        )
        if invoice.present?
          invoice.sync_with(stripe_invoice)
          saved = invoice.save
          Fabric.config.logger.info "InvoiceUpdated: Updated invoice: "\
            "#{stripe_invoice.id} saved: #{saved}"
        else
          Fabric.config.logger.info "InvoiceUpdated: Unable to locate "\
            "invoice. invoice: #{stripe_invoice.id}"
        end
      end

    end
  end
end

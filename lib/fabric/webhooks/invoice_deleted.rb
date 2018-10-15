module Fabric
  module Webhooks
    class InvoiceDeleted
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
          Fabric.config.logger.info "InvoiceDeleted: Deleting invoice: "\
            "#{stripe_invoice.id}"
          invoice.destroy
        else
          Fabric.config.logger.info "InvoiceDeleted: Unable to locate "\
            "invoice: #{stripe_invoice.id}"
        end
      end

    end
  end
end

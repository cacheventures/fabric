module Fabric
  module Webhooks
    class InvoiceDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:invoice)
        handle(event)
      end

      def persist_model(event)
        invoice = retrieve_local(:invoice, event.data.object.id)
        return unless invoice

        invoice.destroy
        Fabric.config.logger.info "InvoiceDeleted: Deleting invoice: "\
          "#{invoice.stripe_id}"
      end

    end
  end
end

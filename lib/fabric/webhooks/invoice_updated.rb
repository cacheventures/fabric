module Fabric
  module Webhooks
    class InvoiceUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_invoice = Stripe::Invoice.retrieve(
          event['data']['object']['id']
        )
        handle(event, stripe_invoice)
        persist_model(stripe_invoice) if Fabric.config.persist?(:invoice)
      end

      def persist_model(stripe_invoice)
        invoice = retrieve_local(:invoice, stripe_invoice.id)
        return unless invoice

        invoice.sync_with(stripe_invoice)
        saved = invoice.save
        Fabric.config.logger.info "InvoiceUpdated: Updated invoice: "\
          "#{invoice.stripe_id} saved: #{saved}"
      end
    end
  end
end

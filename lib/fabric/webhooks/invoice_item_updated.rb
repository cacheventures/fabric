module Fabric
  module Webhooks
    class InvoiceItemUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_invoice_item = retrieve_resource(
          'invoice_item', event['data']['object']['id']
        )
        return if stripe_invoice_item.nil?

        handle(event, stripe_invoice_item)
        if Fabric.config.persist?(:invoice_item)
          persist_model(stripe_invoice_item)
        end
      end

      def persist_model(stripe_invoice_item)
        invoice_item = retrieve_local(:invoice_item, stripe_invoice_item.id)
        return unless invoice_item

        invoice_item.sync_with(stripe_invoice_item)
        saved = invoice_item.save
        Fabric.config.logger.info "InvoiceItemUpdated: Updated invoice item: "\
          "#{invoice_item.stripe_id} saved: #{saved}"
      end
    end
  end
end

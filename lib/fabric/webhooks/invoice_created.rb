module Fabric
  module Webhooks
    class InvoiceCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:customer)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
          unless customer.present?
            Fabric.config.logger.info 'InvoiceCreated: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'InvoiceCreated: ERROR: No customer.'
          return
        end

        account = customer.account
        invoice = Fabric::Invoice.new(
          customer: customer,
          account: account
        )
        invoice.sync_with(event.data.object)
        saved = invoice.save
        Fabric.config.logger.info "InvoiceCreated: Created invoice: "\
          "#{invoice.stripe_id} saved: #{saved}"
      end

    end
  end
end

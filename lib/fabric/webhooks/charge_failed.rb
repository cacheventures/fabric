module Fabric
  module Webhooks
    class ChargeFailed
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
            Fabric.config.logger.info 'ChargeFailed: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'ChargeFailed: ERROR: No customer.'
          return
        end

        charge = Fabric::Charge.new(
          customer: customer
        )
        charge.sync_with(event.data.object)
        saved = charge.save
        Fabric.config.logger.info "ChargeFailed: Created charge: "\
          "#{charge.stripe_id} saved: #{saved}"
      end
    end
  end
end

module Fabric
  module Webhooks
    class DiscountCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        discount = Fabric::Discount.new
        discount.sync_with(event.data.object)
        unless discount.customer.present?
          Fabric.config.logger.info 'DiscountCreated: No matching customer.'
          return
        end

        saved = discount.save
        Fabric.config.logger.info "DiscountCreated: Created discount: "\
          "#{discount.id} saved: #{saved}"
      end

    end
  end
end

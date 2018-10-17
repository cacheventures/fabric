module Fabric
  module Webhooks
    class DiscountCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:discount)
        handle(event)
      end

      def persist_model(event)
        discount = Fabric::Discount.new
        discount.sync_with(event.data.object)
        saved = discount.save
        Fabric.config.logger.info "DiscountCreated: Created discount: "\
          "#{discount.id} saved: #{saved}"
      end

    end
  end
end

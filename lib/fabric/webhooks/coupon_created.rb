module Fabric
  module Webhooks
    class CouponCreated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        coupon = Fabric::Coupon.new
        coupon.sync_with(event.data.object)
        saved = coupon.save
        Fabric.config.logger.info "CouponCreated: Created coupon: "\
          "#{coupon.stripe_id} saved: #{saved}"
      end

    end
  end
end

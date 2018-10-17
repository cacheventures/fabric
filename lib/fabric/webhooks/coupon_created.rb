module Fabric
  module Webhooks
    class CouponCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:coupon)
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

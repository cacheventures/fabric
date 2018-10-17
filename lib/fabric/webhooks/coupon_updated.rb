module Fabric
  module Webhooks
    class CouponUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:coupon)
        handle(event)
      end

      def persist_model(event)
        stripe_coupon = event.data.object
        coupon = retrieve_local(:coupon, stripe_coupon.id)
        return unless coupon
        return unless most_recent_update?(coupon, event)

        coupon.sync_with(stripe_coupon)
        saved = coupon.save
        Fabric.config.logger.info "CouponUpdated: Updated coupon: "\
          "#{coupon.stripe_id} saved: #{saved}"
      end

    end
  end
end

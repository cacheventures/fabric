module Fabric
  module Webhooks
    class CouponCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_coupon = Stripe::Coupon.retrieve(event['data']['object']['id'])
        handle(event, stripe_coupon)
        persist_model(stripe_coupon) if Fabric.config.persist?(:coupon)
      end

      def persist_model(stripe_coupon)
        coupon = Fabric::Coupon.new
        coupon.sync_with(stripe_coupon)
        saved = coupon.save
        Fabric.config.logger.info "CouponCreated: Created coupon: "\
          "#{coupon.stripe_id} saved: #{saved}"
      end

    end
  end
end

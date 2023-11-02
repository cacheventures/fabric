module Fabric
  module Webhooks
    class CouponUpdated
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_coupon = retrieve_resource(
          'coupon', event['data']['object']['id'], expand: %w(currency_options)
        )
        return if stripe_coupon.nil?

        handle(event, stripe_coupon)
        persist_model(stripe_coupon) if Fabric.config.persist?(:coupon)
      end

      def persist_model(stripe_coupon)
        coupon = retrieve_local(:coupon, stripe_coupon.id)
        return unless coupon

        coupon.sync_with(stripe_coupon)
        saved = coupon.save
        Fabric.config.logger.info "CouponUpdated: Updated coupon: "\
          "#{coupon.stripe_id} saved: #{saved}"
      end

    end
  end
end

module Fabric
  module Webhooks
    class CouponUpdated
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:coupon)

        handle(event)
      end

      def persist_model(event)
        coupon = Fabric::Coupon.find_by(stripe_id: event.data.object.id)
        unless coupon.present?
          Fabric.config.logger.info 'CouponUpdated: No matching coupon.'
          return
        end
        coupon.sync_with(event.data.object)
        saved = coupon.save
        Fabric.config.logger.info "CouponUpdated: Updated coupon: "\
          "#{coupon.stripe_id} saved: #{saved}"
      end

    end
  end
end

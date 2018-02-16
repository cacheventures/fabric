module Fabric
  module Webhooks
    class CouponDeleted
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        coupon = Fabric::Coupon.find_by(stripe_id: event.data.object.id)
        unless coupon.present?
          Fabric.config.logger.info 'CouponDeleted: Coupon not found.'
          return
        end
        coupon.destroy
        Fabric.config.logger.info "CouponDeleted: Destroyed coupon: "\
          "#{coupon.stripe_id}"
      end

    end
  end
end

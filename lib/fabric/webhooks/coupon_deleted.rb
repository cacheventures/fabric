module Fabric
  module Webhooks
    class CouponDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        handle(event)
        persist_model(event) if Fabric.config.persist?(:coupon)
      end

      def persist_model(event)
        coupon = retrieve_local(:coupon, event['data']['object']['id'])
        return unless coupon

        coupon.destroy
        Fabric.config.logger.info "CouponDeleted: Destroyed coupon: "\
          "#{coupon.stripe_id}"
      end

    end
  end
end

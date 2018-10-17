module Fabric
  module Webhooks
    class DiscountDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:discount)
        handle(event)
      end

      def persist_model(event)
        stripe_discount = event.data.object
        customer = retrieve_local(:customer, stripe_discount.customer)
        subscription = retrieve_local(
          :subscription, stripe_discount.subscription
        )
        coupon = retrieve_local(:coupon, stripe_discount.coupon.id)
        return unless coupon
        if customer
          discount = Fabric::Discount.find_by(customer: customer)
        elsif subscription
          discount = Fabric::Discount.find_by(subscription: subscription)
        end
        return unless discount

        discount.destroy
        Fabric.config.logger.info "DiscountDeleted: Destroyed discount: "\
          "#{discount.id}"
      end

    end
  end
end

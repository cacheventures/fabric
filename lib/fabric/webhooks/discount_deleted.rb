module Fabric
  module Webhooks
    class DiscountDeleted
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        customer_id = event.try(:data).try(:object).try(:customer)
        if customer_id.present?
          customer = Fabric::Customer.find_by(stripe_id: customer_id)
          unless customer.present?
            Fabric.config.logger.info 'DiscountDeleted: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'DiscountDeleted: No customer.'
          return
        end

        coupon_id = event.data.object.coupon.id
        coupon = Fabric::Coupon.find_by(stripe_id: coupon_id)
        if coupon.present?
          discount = customer.discounts.find_by(coupon: coupon)
        else
          discount = nil
        end

        if discount.present?
          discount.destroy
          Fabric.config.logger.info "DiscountDeleted: Destroyed discount: "\
            "#{discount.id}"
        else
          Fabric.config.logger.info 'DiscountDeleted: Discount not found.'
        end
      end

    end
  end
end

module Fabric
  module Webhooks
    class DiscountUpdated
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
            Fabric.config.logger.info 'DiscountUpdated: No matching customer.'
            return
          end
        else
          Fabric.config.logger.info 'DiscountUpdated: No customer.'
          return
        end

        prev_coupon_id = event.data.previous_attributes.coupon.id
        prev_coupon = Fabric::Coupon.find_by(stripe_id: prev_coupon_id)
        if prev_coupon.present?
          discount = customer.discounts.find_by(coupon: prev_coupon)
        else
          discount = nil
        end
        if discount.present?
          discount.destroy
          Fabric.config.logger.info "DiscountUpdated: Destroyed discount: "\
            "#{discount.id}"
          discount = customer.discounts.new
        else
          Fabric.config.logger.info 'DiscountUpdated: Discount not found.'
          discount = customer.discounts.new
        end
        discount.sync_with(event.data.object)
        saved = discount.save
        Fabric.config.logger.info "DiscountUpdated: Created discount: "\
          "#{discount.id} saved: #{saved}"
      end

    end
  end
end

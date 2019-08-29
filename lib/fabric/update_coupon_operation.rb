module Fabric
  class UpdateCouponOperation
    include Fabric

    def initialize(coupon, attributes = {})
      @log_data = {
        class: self.class.name, coupon: coupon, attributes: attributes
      }
      flogger.json_info 'Started', @log_data
      @coupon = get_document(Fabric::Coupon, coupon)
      @attributes = attributes
    end

    def call
      stripe_coupon = Stripe::Coupon.update(@coupon.stripe_id, @attributes)
      @coupon.sync_with(stripe_coupon)
      saved = @coupon.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@coupon, stripe_coupon]
    end
  end
end

module Fabric
  class DeleteCouponOperation
    include Fabric

    def initialize(coupon)
      @log_data = { class: self.class.name, coupon: coupon }
      flogger.json_info 'Started', @log_data
      @coupon = get_document(Fabric::Coupon, coupon)
    end

    def call
      stripe_delete = Stripe::Coupon.delete(@coupon.stripe_id)
      destroyed = @coupon.destroy

      flogger.json_info 'Completed', @log_data.merge(
        stripe_delete: stripe_delete, destroyed: destroyed
      )
    end
  end
end

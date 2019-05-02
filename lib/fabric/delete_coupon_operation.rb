module Fabric
  class DeleteCouponOperation
    include Fabric

    def initialize(coupon)
      Fabric.config.logger.info "DeleteCouponOperation: Started with "\
        "#{coupon}"
      @coupon = get_document(Fabric::Coupon, coupon)
    end

    def call
      stripe_coupon = Stripe::Coupon.retrieve(@coupon.stripe_id)
      stripe_coupon.delete
      deleted = @coupon.destroy
      Fabric.config.logger.info "DeleteCouponOperation: Completed. "\
        "deleted: #{deleted}"
    end
  end
end

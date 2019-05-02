module Fabric
  class CreateCouponOperation
    include Fabric

    def initialize(attributes = {})
      Fabric.config.logger.info "CreateCouponOperation: Started with "\
        "#{attributes}"
      @attributes = attributes
    end

    def call
      stripe_coupon = Stripe::Coupon.create(@attributes)
      coupon = Fabric::Coupon.new
      coupon.sync_with(stripe_coupon)
      saved = coupon.save
      Fabric.config.logger.info "CreateCouponOperation: Completed. "\
        "saved: #{saved}"
      coupon
    end
  end
end

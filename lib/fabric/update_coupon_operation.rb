module Fabric
  class UpdateCouponOperation
    include Fabric

    def initialize(coupon, attributes = {})
      Fabric.config.logger.info "UpdateCouponOperation: Started with "\
        "#{coupon} #{attributes}"
      @coupon = get_document(Fabric::Coupon, coupon)
      @attributes = attributes
    end

    def call
      stripe_coupon = Stripe::Coupon.retrieve(@coupon.stripe_id)
      @attributes.each { |k, v| stripe_coupon.send("#{k}=", v) }
      stripe_coupon.save
      coupon.sync_with(stripe_coupon)
      saved = coupon.save
      Fabric.config.logger.info "UpdateCouponOperation: Completed. "\
        "saved: #{saved}"
    end
  end
end

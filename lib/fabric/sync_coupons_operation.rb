module Fabric
  class SyncCouponsOperation
    include Fabric

    def call
      Fabric.config.logger.info "SyncCouponsOperation: Fetching all coupons "\
        "and syncing with any local copies."
      stripe_coupons = Stripe::Coupon.all
      stripe_coupons.each do |c|
        coupon = Fabric::Coupon.find_by(stripe_id: c.id) || Fabric::Coupon.new
        coupon.sync_with(c)
        coupon.save
      end
    end
  end
end

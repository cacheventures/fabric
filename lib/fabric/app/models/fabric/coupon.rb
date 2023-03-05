module Fabric
  class Coupon
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    field :stripe_id, type: String
    field :amount_off, type: Integer
    field :created, type: Time
    field :currency, type: String
    field :duration, type: String
    enumerize :duration, in: %w(forever once repeating)
    field :duration_in_months, type: Integer
    field :livemode, type: Boolean
    field :max_redemptions, type: Integer
    field :metadata, type: Hash
    field :name, type: String
    field :percent_off, type: Integer
    field :redeem_by, type: Time
    field :times_redeemed, type: Integer
    field :coupon_valid, type: Boolean

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :duration, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(coupon)
      self.stripe_id = stripe_id_for(coupon)
      self.amount_off = coupon.amount_off
      self.created = coupon.created
      self.currency = coupon.currency
      self.duration = coupon.duration
      self.duration_in_months = coupon.duration_in_months
      self.livemode = coupon.livemode
      self.max_redemptions = coupon.max_redemptions
      self.metadata = convert_metadata(coupon.metadata)
      self.name = coupon.name
      self.percent_off = coupon.percent_off
      self.redeem_by = coupon.redeem_by
      self.times_redeemed = coupon.times_redeemed
      self.coupon_valid = coupon_valid_for(coupon)
      self
    end

    def usable?
      return false unless coupon_valid
      if redeem_by.present?
        return false unless redeem_by > Time.now
      end
      if max_redemptions.present?
        return times_redeemed < max_redemptions
      end
      true
    end

    private

    def coupon_valid_for(coupon)
      if coupon.is_a? Stripe::APIResource
        coupon.valid
      elsif coupon.is_a? Mongoid::Document
        coupon.coupon_valid
      else
        fail InvalidResourceError, coupon.to_s
      end
    end

  end
end

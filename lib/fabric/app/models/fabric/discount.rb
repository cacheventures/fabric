module Fabric
  class Discount
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

    field :object, type: String
    field :coupon, type: Hash
    field :customer, type: String
    field :end, type: Time
    field :start, type: Time
    field :subscription, type: String

    validates :start, :customer, :coupon, presence: true

    def sync_with(discount)
      self.object = discount.object
      self.coupon = discount.coupon.to_hash
      self.customer = discount.customer
      self.end = discount.end
      self.start = discount.start
      self.subscription = discount.subscription
      self
    end
  end
end

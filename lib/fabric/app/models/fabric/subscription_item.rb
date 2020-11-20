module Fabric
  class SubscriptionItem
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :subscription, class_name: 'Fabric::Subscription',
      primary_key: :stripe_id
    belongs_to :plan, class_name: 'Fabric::Plan',
      primary_key: :stripe_id, inverse_of: :subscription_items
    belongs_to :price, class_name: 'Fabric::Price',
      primary_key: :stripe_id, inverse_of: :subscription_items
    has_many :usage_records, class_name: 'Fabric::UsageRecord',
      primary_key: :stripe_id, dependent: :destroy

    field :stripe_id, type: String
    field :metadata, type: Hash
    field :quantity, type: Integer

    validates_uniqueness_of :stripe_id
    validates_presence_of :stripe_id

    index({ stripe_id: 1 }, { background: true, unique: true })

    def sync_with(sub_item)
      self.stripe_id = Fabric.stripe_id_for sub_item
      self.metadata = Fabric.convert_metadata(sub_item.metadata.to_hash)
      self.plan_id = Fabric.stripe_id_for(sub_item.plan)
      self.price_id = Fabric.stripe_id_for(sub_item.price)
      self.quantity = sub_item.quantity if sub_item.try(:quantity).present?
      self.subscription_id = sub_item.subscription
      self
    end
  end
end

module Fabric
  class SubscriptionItem
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :subscription, class_name: 'Fabric::Subscription'
    belongs_to :plan, class_name: 'Fabric::Plan',
                      inverse_of: :subscription_items
    has_many :usage_records, class_name: 'Fabric::UsageRecord'

    field :stripe_id, type: String
    field :metadata, type: Hash
    field :quantity, type: Integer

    validates_presence_of :stripe_id, :quantity

    def sync_with(sub_item)
      self.stripe_id = Fabric.stripe_id_for sub_item
      self.metadata = sub_item.metadata.to_hash
      self.quantity = sub_item.quantity
      self.plan = Fabric::Plan.find_by(
        stripe_id: Fabric.stripe_id_for(sub_item.plan)
      )
      self
    end
  end
end

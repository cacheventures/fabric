module Fabric
  class Source
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer', inverse_of: :sources,
      primary_key: :stripe_id, touch: true

    field :stripe_id, type: String
    field :amount, type: Integer
    field :client_secret, type: String
    field :code_verification, type: Hash # optional
    field :created, type: Time
    field :currency, type: String
    field :flow, type: String
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :owner, type: Hash
    field :receiver, type: Hash # optional
    field :redirect, type: Hash # optional
    field :source_order, type: Hash # optional
    field :statement_descriptor, type: String
    field :status, type: String
    field :type, type: String
    field :usage, type: String

    validates_uniqueness_of :stripe_id
    validates :stripe_id, :customer_id, :type, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ customer_id: 1 }, background: true)

    def sync_with(source)
      self.stripe_id = source.id
      self.amount = source.amount
      self.client_secret = source.client_secret
      self.code_verification = handle_hash(source.try(:code_verification))
      self.created = source.created
      self.currency = source.currency
      self.customer_id = handle_expanded(source.customer)
      self.flow = source.flow
      self.livemode = source.livemode
      self.metadata = convert_metadata(source.metadata)
      self.owner = handle_hash(source.owner)
      self.receiver = handle_hash(source.try(:receiver))
      self.redirect = handle_hash(source.try(:redirect))
      self.source_order = handle_hash(source.try(:source_order))
      self.statement_descriptor = source.statement_descriptor
      self.status = source.status
      self.type = source.type
      self.usage = source.usage
      self
    end

  end
end

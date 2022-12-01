module Fabric
  class Source
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer', inverse_of: :sources,
      primary_key: :stripe_id, touch: true

    field :stripe_id, type: String

    # different types each have a hash with their name as the key. only one
    # will exist at a time.
    field :ach_credit_transfer, type: Hash
    field :ach_debit, type: Hash
    field :alipay, type: Hash
    field :bancontact, type: Hash
    field :card, type: Hash
    field :card_present, type: Hash
    field :eps, type: Hash
    field :giropay, type: Hash
    field :ideal, type: Hash
    field :multibanco, type: Hash
    field :klarna, type: Hash
    field :p24, type: Hash
    field :sepa_debit, type: Hash
    field :sofort, type: Hash
    field :three_d_secure, type: Hash
    field :wechat, type: Hash

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
      self.stripe_id = Fabric.stripe_id_for(source)

      self.ach_credit_transfer =
        source.try(:ach_credit_transfer)&.to_hash&.with_indifferent_access
      self.ach_debit = source.try(:ach_debit)&.to_hash&.with_indifferent_access
      self.alipay = source.try(:alipay)&.to_hash&.with_indifferent_access
      self.bancontact = source.try(:bancontact)&.to_hash&.with_indifferent_access
      self.card = source.try(:card)&.to_hash&.with_indifferent_access
      self.card_present = source.try(:card_present)&.to_hash&.with_indifferent_access
      self.eps = source.try(:eps)&.to_hash&.with_indifferent_access
      self.giropay = source.try(:giropay)&.to_hash&.with_indifferent_access
      self.ideal = source.try(:ideal)&.to_hash&.with_indifferent_access
      self.multibanco = source.try(:multibanco)&.to_hash&.with_indifferent_access
      self.klarna = source.try(:klarna)&.to_hash&.with_indifferent_access
      self.p24 = source.try(:p24)&.to_hash&.with_indifferent_access
      self.sepa_debit = source.try(:sepa_debit)&.to_hash&.with_indifferent_access
      self.sofort = source.try(:sofort)&.to_hash&.with_indifferent_access
      self.three_d_secure = source.try(:three_d_secure)&.to_hash&.with_indifferent_access
      self.wechat = source.try(:wechat)&.to_hash&.with_indifferent_access

      self.amount = source.amount
      self.client_secret = source.client_secret
      self.code_verification =
        source.try(:code_verification)&.to_hash&.with_indifferent_access
      self.created = source.created
      self.currency = source.currency
      self.customer_id = source.customer
      self.flow = source.flow
      self.livemode = source.livemode
      self.metadata = Fabric.convert_metadata(source.metadata)
      self.owner = source.owner&.to_hash&.with_indifferent_access
      self.receiver = source.try(:receiver)&.to_hash&.with_indifferent_access
      self.redirect = source.try(:redirect)&.to_hash&.with_indifferent_access
      self.source_order =
        source.try(:source_order)&.to_hash&.with_indifferent_access
      self.statement_descriptor = source.statement_descriptor
      self.status = source.status
      self.type = source.type
      self.usage = source.usage
      self
    end

  end
end

module Fabric
  class Source
    include Mongoid::Document
    include Mongoid::Timestamps
    extend Enumerize

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

      self.ach_credit_transfer = source.try(:ach_credit_transfer).try(:to_hash)
      self.ach_debit = source.try(:ach_debit).try(:to_hash)
      self.alipay = source.try(:alipay).try(:to_hash)
      self.bancontact = source.try(:bancontact).try(:to_hash)
      self.card = source.try(:card).try(:to_hash)
      self.card_present = source.try(:card_present).try(:to_hash)
      self.eps = source.try(:eps).try(:to_hash)
      self.giropay = source.try(:giropay).try(:to_hash)
      self.ideal = source.try(:ideal).try(:to_hash)
      self.multibanco = source.try(:multibanco).try(:to_hash)
      self.klarna = source.try(:klarna).try(:to_hash)
      self.p24 = source.try(:p24).try(:to_hash)
      self.sepa_debit = source.try(:sepa_debit).try(:to_hash)
      self.sofort = source.try(:sofort).try(:to_hash)
      self.three_d_secure = source.try(:three_d_secure).try(:to_hash)
      self.wechat = source.try(:wechat).try(:to_hash)

      self.amount = source.amount
      self.client_secret = source.client_secret
      self.code_verification = source.try(:code_verification).try(:to_hash)
      self.created = source.created
      self.currency = source.currency
      self.customer_id = source.customer
      self.flow = source.flow
      self.livemode = source.livemode
      self.metadata = Fabric.convert_metadata(source.metadata.to_hash)
      self.owner = source.owner.try(:to_hash)
      self.receiver = source.try(:receiver).try(:to_hash)
      self.redirect = source.try(:redirect).try(:to_hash)
      self.source_order = source.try(:source_order).try(:to_hash)
      self.statement_descriptor = source.statement_descriptor
      self.status = source.status
      self.type = source.type
      self.usage = source.usage
      self
    end

  end
end

module Fabric
  class FundingInstructions
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    embedded_in :customer, class_name: 'Fabric::Customer'

    field :object, type: String
    field :bank_transfer, type: Hash, default: { type: 'us_bank_transfer' }
    field :currency, type: String, default: 'usd'
    field :funding_type, type: String, default: 'bank_transfer'
    field :livemode, type: Boolean

    def sync_with(funding_instructions)
      self.object = funding_instructions.object
      self.bank_transfer = handle_hash(funding_instructions.bank_transfer)
      self.currency = funding_instructions.currency
      self.funding_type = funding_instructions.funding_type
      self.livemode = funding_instructions.livemode
      self
    end

    def sync_from_stripe
      stripe_customer = Stripe::Customer.retrieve(customer.stripe_id)
      stripe_funding_instructions = stripe_customer.create_funding_instructions(
        currency: self.currency,
        funding_type: self.funding_type,
        bank_transfer: { type: self.bank_transfer[:type] }
      )
      sync_with(stripe_funding_instructions)
      self
    end

  end
end

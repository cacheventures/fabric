module Fabric
  class Invoice
    include Base
    include Mongoid::Document
    include Mongoid::Timestamps

    belongs_to :customer, class_name: 'Fabric::Customer',
      primary_key: :stripe_id
    has_many :charges, class_name: 'Fabric::Charge',
      primary_key: :stripe_id, dependent: :destroy
    has_one :payment_intent, class_name: 'Fabric::PaymentIntent',
      primary_key: :stripe_id, dependent: :destroy
    has_one :subscription, class_name: 'Fabric::Subscription',
      primary_key: :latest_invoice_id

    field :stripe_id, type: String
    field :account_country, type: String
    field :account_name, type: String
    field :amount_due, type: Integer
    field :amount_paid, type: Integer
    field :amount_remaining, type: Integer
    field :application_fee, type: Integer
    field :attempt_count, type: Integer
    field :attempted, type: Boolean
    field :auto_advance, type: Boolean
    field :billing_reason, type: String
    field :closed, type: Boolean # Deprecated
    field :collection_method, type: String
    field :created, type: Time
    field :currency, type: String
    field :custom_fields, type: Array
    field :customer_address, type: Hash
    field :customer_email, type: String
    field :customer_name, type: String
    field :customer_phone, type: String
    field :customer_shipping, type: Hash
    field :customer_tax_exempt, type: String
    field :customer_tax_ids, type: Array
    field :date, type: Time
    field :default_payment_method, type: String
    field :default_source, type: String
    field :default_tax_rates, type: Array
    field :description, type: String
    field :discount, type: Hash
    field :due_date, type: Time
    field :ending_balance, type: Integer
    field :footer, type: String
    field :forgiven, type: Boolean
    field :hosted_invoice_url, type: String
    field :invoice_pdf, type: String
    field :lines, type: Array
    field :livemode, type: Boolean
    field :metadata, type: Hash
    field :next_payment_attempt, type: Time
    field :number, type: String
    field :paid, type: Boolean
    field :period_end, type: Time
    field :period_start, type: Time
    field :post_payment_credit_notes_amount, type: Integer
    field :pre_payment_credit_notes_amount, type: Integer
    field :receipt_number, type: String
    field :starting_balance, type: Integer
    field :statement_descriptor, type: String
    field :status, type: String
    field :status_transitions, type: Hash
    field :subscription_proration_date, type: Time
    field :subtotal, type: Integer
    field :tax, type: Integer
    field :threshold_reason, type: Hash
    field :total, type: Integer
    field :total_tax_amounts, type: Array
    field :webhooks_delivered_at, type: Time

    validates_uniqueness_of :stripe_id
    validates :customer_id, :stripe_id, presence: true

    index({ stripe_id: 1 }, { background: true, unique: true })
    index({ customer_id: 1, subscription_id: 1 }, background: true)

    def sync_with(invoice)
      self.stripe_id = stripe_id_for(invoice)
      self.account_country = invoice.account_country
      self.account_name = invoice.account_name
      self.amount_due = invoice.amount_due
      self.amount_paid = invoice.amount_paid
      self.amount_remaining = invoice.amount_remaining
      self.application_fee = invoice.application_fee
      self.attempt_count = invoice.attempt_count
      self.attempted = invoice.attempted
      self.auto_advance = invoice.auto_advance
      self.billing_reason = invoice.billing_reason
      self.closed = invoice.closed
      self.collection_method = invoice.collection_method
      self.created = invoice.created
      self.currency = invoice.currency
      self.customer_id = handle_expanded(invoice.customer)
      self.custom_fields = invoice.custom_fields&.map do |e|
        handle_hash(e.to_hash)
      end
      self.customer_address = handle_hash(invoice.customer_address)
      self.customer_email = invoice.customer_email
      self.customer_name = invoice.customer_name
      self.customer_phone = invoice.customer_phone
      self.customer_shipping = handle_hash(invoice.customer_shipping)
      self.customer_tax_ids = invoice.customer_tax_ids&.map do |e|
        handle_hash(e)
      end
      self.date = invoice.date
      self.default_payment_method = invoice.default_payment_method
      self.default_source = invoice.default_source
      self.default_tax_rates = invoice.default_tax_rates
      self.description = invoice.description
      self.discount = handle_hash(invoice.discount)
      self.due_date = invoice.due_date
      self.ending_balance = invoice.ending_balance
      self.footer = invoice.footer
      self.forgiven = invoice.forgiven
      self.hosted_invoice_url = invoice.hosted_invoice_url
      self.invoice_pdf = invoice.invoice_pdf
      self.lines = handle_hash(invoice.lines).dig(:data)
      self.livemode = invoice.livemode
      self.metadata = convert_metadata(invoice.metadata)
      self.next_payment_attempt = invoice.next_payment_attempt
      self.number = invoice.number
      self.paid = invoice.paid
      self.period_end = invoice.period_end
      self.period_start = invoice.period_start
      self.post_payment_credit_notes_amount = invoice.post_payment_credit_notes_amount
      self.pre_payment_credit_notes_amount = invoice.pre_payment_credit_notes_amount
      self.receipt_number = invoice.receipt_number
      self.starting_balance = invoice.starting_balance
      self.statement_descriptor = invoice.statement_descriptor
      self.status = invoice.status
      self.status_transitions = handle_hash(invoice.status_transitions)
      self.subscription_proration_date = invoice.try(:subscription_proration_date)
      self.subtotal = invoice.subtotal
      self.tax = invoice.tax
      self.threshold_reason = handle_hash(invoice.try(:threshold_reason))
      self.total = invoice.total
      self.total_tax_amounts = invoice.total_tax_amounts
      self.webhooks_delivered_at = invoice.webhooks_delivered_at
      self
    end

    def charge
      charges.sort { |c| c.created }.first
    end

  end
end

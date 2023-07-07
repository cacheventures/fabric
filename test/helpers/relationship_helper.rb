def customer
  @customer ||= Fabric::Customer.create!(
    stripe_id: 'cust_xxx',
    created: Time.now,
    default_source: 'src_xxx'
  )
end

def invoice
  @invoice ||= Fabric::Invoice.create!(
    customer_id: 'cust_xxx',
    charge_id: 'ch_xxx',
    stripe_id: 'invc_xxx'
  )
end

def payment_intent
  @payment_intent ||= Fabric::PaymentIntent.create!(
    customer_id: 'cust_xxx',
    stripe_id: 'pi_xxx',
    invoice_id: 'invc_xxx'
  )
end

def charge
  @charge ||= Fabric::Charge.create!(
    customer_id: 'cust_xxx',
    invoice_id: 'invc_xxx',
    stripe_id: 'ch_xxx',
    payment_intent_id: 'pi_xxx'
  )
end

def dispute
  @dispute ||= Fabric::Dispute.create!(
    charge_id: 'ch_xxx',
    payment_intent_id: 'pi_xxx',
    stripe_id: 'dis_xxx'
  )
end

def event
  @event ||= Fabric::Event.create!(
    customer_id: 'cust_xxx',
    api_version: '2018-02-28',
    webhook: 'test.webhook',
    stripe_id: 'ev_xxx'
  )
end

def invoice_item
  @invoice_item ||= Fabric::InvoiceItem.create!(
    stripe_id: 'invi_xxx',
    customer_id: 'cust_xxx'
  )
end

def payment_method
  @payment_method ||= Fabric::PaymentMethod.create!(
    stripe_id: 'pm_xxx',
    customer_id: 'cust_xxx'
  )
end

def subscription
  @subscription ||= Fabric::Subscription.create!(
    stripe_id: 'sub_xxx',
    customer_id: 'cust_xxx',
    default_payment_method_id: 'pm_xxx',
    cancel_at_period_end: false,
    status: 'active',
    current_period_end: 1.month.from_now,
    current_period_start: Time.now
  )
end

def plan
  @plan ||= Fabric::Plan.create!(
    stripe_id: 'plan_xxx',
    amount: 100,
    currency: 'usd',
    interval: 'month',
    created: Time.now,
    product_id: 'prod_xxx'
  )
end

def subscription_item
  @subscription_item ||= Fabric::SubscriptionItem.create!(
    stripe_id: 'subi_xxx',
    subscription_id: 'sub_xxx',
    plan_id: 'plan_xxx',
    price_id: 'price_xxx'
  )
end

def price
  @price ||= Fabric::Price.create!(
    stripe_id: 'price_xxx',
    product_id: 'prod_xxx',
    currency: 'usd'
  )
end

def product
  @product ||= Fabric::Product.create!(
    stripe_id: 'prod_xxx',
    name: 'test product'
  )
end

def setup_intent
  @setup_intent ||= Fabric::SetupIntent.create!(
    stripe_id: 'si_xxx',
    customer_id: 'cust_xxx'
  )
end

def source
  @source ||= Fabric::Source.create!(
    stripe_id: 'src_xxx',
    customer_id: 'cust_xxx',
    type: 'card'
  )
end

def usage_record
  @usage_record ||= Fabric::UsageRecord.create!(
    stripe_id: 'ur_xxx',
    customer_id: 'cust_xxx',
    subscription_item_id: 'subi_xxx',
    quantity: 1,
    timestamp: Time.now
  )
end

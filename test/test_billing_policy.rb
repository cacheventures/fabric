require 'minitest/autorun'
require 'fabric'

class TestBillingPolicy < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
    Fabric::Plan.create(
      stripe_id: '100',
      amount: 10000,
      currency: 'usd',
      interval: 'month',
      created: Time.now,
      product: 'prod_0'
    )
  end

  def teardown
    Fabric::Subscription.update_all(customer: nil)
    Fabric::Subscription.destroy_all
    Fabric::Customer.destroy_all
    Fabric::PaymentMethod.destroy_all
    Fabric::Plan.destroy_all
  end

  def test_billing_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )
    Fabric::Subscription.create(
      stripe_id: 'sub_0',
      cancel_at_period_end: false,
      customer: customer,
      start: Time.now,
      status: 'active',
      current_period_end: 30.days.from_now,
      current_period_start: Time.now
    )
    bp = Fabric::BillingPolicy.new(customer)
    assert bp.billing?
  end

  def test_billing_not_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )

    bp = Fabric::BillingPolicy.new(customer)
    refute bp.billing?
  end

  def test_has_subscription_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )
    Fabric::Subscription.create(
      stripe_id: 'sub_0',
      cancel_at_period_end: false,
      customer: customer,
      start: Time.now,
      status: 'past_due',
      current_period_end: 30.days.from_now,
      current_period_start: Time.now
    )

    bp = Fabric::BillingPolicy.new(customer)
    assert bp.has_subscription?
  end

  def test_has_subscription_not_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )

    bp = Fabric::BillingPolicy.new(customer)
    refute bp.has_subscription?
  end

  def test_billable_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )
    Fabric::PaymentMethod.create(
      stripe_id: 'payment_method_0',
      customer: customer,
      card: {
        last4: '1234',
        brand: 'American Express',
        exp_month: 1,
        exp_year: 2030
      }
    )

    bp = Fabric::BillingPolicy.new(customer)
    assert bp.billable?
  end

  def test_billable_not_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now
    )

    bp = Fabric::BillingPolicy.new(customer)
    refute bp.billable?
  end

  def test_has_unpaid_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )
    Fabric::Subscription.create(
      stripe_id: 'sub_0',
      cancel_at_period_end: false,
      customer: customer,
      start: Time.now,
      status: 'unpaid',
      current_period_end: 30.days.from_now,
      current_period_start: Time.now
    )

    bp = Fabric::BillingPolicy.new(customer)
    assert bp.has_unpaid?
  end

  def test_has_unpaid_not_present
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )
    Fabric::Subscription.create(
      stripe_id: 'sub_0',
      cancel_at_period_end: false,
      customer: customer,
      start: Time.now,
      status: 'active',
      current_period_end: 30.days.from_now,
      current_period_start: Time.now
    )

    bp = Fabric::BillingPolicy.new(customer)
    refute bp.has_unpaid?
  end

end

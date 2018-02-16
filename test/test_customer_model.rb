require 'minitest/autorun'
require 'fabric'

class TestCustomerModel < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
  end

  def teardown
    Fabric::Customer.destroy_all
    Fabric::Card.destroy_all
    Fabric::Plan.destroy_all
  end

  def test_customer_source_method
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      default_source: 'card_0'
    )
    default_card = Fabric::Card.create(
      stripe_id: 'card_0',
      customer: customer,
      last4: '1234',
      brand: 'American Express',
      exp_month: 1,
      exp_year: 2030
    )
    alternate_card = Fabric::Card.create(
      stripe_id: 'card_1',
      customer: customer,
      last4: '5678',
      brand: 'Visa',
      exp_month: 2,
      exp_year: 2028
    )
    assert_equal default_card, customer.source
  end

  def test_customer_plan_method
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now
    )
    only_plan = Fabric::Plan.create(
      stripe_id: '0',
      amount: 1000,
      currency: 'usd',
      interval: 'month',
      created: Time.now,
      name: 'Ten Bucks'
    )

    assert_equal Fabric.default_plan, customer.plan
  end

end

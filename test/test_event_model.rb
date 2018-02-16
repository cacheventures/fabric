require 'minitest/autorun'
require 'fabric'

class TestEventModel < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
  end

  def teardown
    Fabric::Customer.destroy_all
    Fabric::Event.destroy_all
  end

  def test_stripe_object_id_method
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now
    )
    event = Fabric::Event.create(
      webhook: 'customer.updated',
      data: { object: { id: 'cus_0' } },
      customer: customer
    )

    assert_equal 'cus_0', event.stripe_object_id
  end

  def test_stripe_customer_method_object_is_customer
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now
    )
    event = Fabric::Event.create(
      webhook: 'customer.updated',
      data: { object: { id: 'cus_0', object: 'customer' } },
      customer: customer
    )

    assert_equal 'cus_0', event.stripe_customer
  end

  def test_stripe_customer_method_object_is_not_customer
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now
    )
    event = Fabric::Event.create(
      webhook: 'customer.subscription.updated',
      data: {
        object: {
          id: 'sub_0',
          object: 'subscription',
          customer: 'cus_0'
        }
      },
      customer: customer
    )

    assert_equal 'cus_0', event.stripe_customer
  end

  def test_stripe_customer_method_without_data
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now
    )
    event = Fabric::Event.create(
      webhook: 'customer.updated',
      customer: customer
    )

    assert_nil event.stripe_customer
  end

end

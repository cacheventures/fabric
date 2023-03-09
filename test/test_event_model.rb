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

  def test_extract_customer_id_with_customer_data_object
    data = {
      object: {
        object: 'customer',
        id: 'cus_xxx',
        customer: nil
      }
    }.deep_stringify_keys
    customer_id = Fabric::Event.extract_customer_id(data)
    assert_equal 'cus_xxx', customer_id
    refute_nil customer_id
  end

  def test_extract_customer_id_with_payment_intent_data_object
    data = {
      object: {
        object: 'payment_intent',
        id: 'pi_xxx',
        customer: 'cus_xxx'
      }
    }.deep_stringify_keys
    customer_id = Fabric::Event.extract_customer_id(data)
    assert_equal 'cus_xxx', customer_id
    refute_equal 'pi_xxx', customer_id
  end

end

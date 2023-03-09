require 'minitest/autorun'
require 'fabric'

class TestCustomerModel < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
  end

  def teardown
    Fabric::Customer.destroy_all
    Fabric::PaymentMethod.destroy_all
    Fabric::Plan.destroy_all
  end

  def test_customer_default_payment_method
    customer = Fabric::Customer.create(
      stripe_id: 'cus_0',
      created: Time.now,
      invoice_settings: { default_payment_method: 'payment_method_0' }
    )
    default_payment_method = Fabric::PaymentMethod.create(
      stripe_id: 'payment_method_0',
      customer: customer,
      card: {
        last4: '1234',
        brand: 'American Express',
        exp_month: 1,
        exp_year: 2030
      }
    )
    Fabric::PaymentMethod.create(
      stripe_id: 'payment_method_1',
      customer: customer,
      card: {
        last4: '5678',
        brand: 'Visa',
        exp_month: 2,
        exp_year: 2028
      }
    )
    assert_equal(
      default_payment_method.stripe_id,
      customer.invoice_settings[:default_payment_method]
    )
  end

end

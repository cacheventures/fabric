require 'minitest/autorun'
require 'fabric'

class TestRelationships < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
  end

  def teardown
    Fabric::Customer.destroy_all
    Fabric::PaymentIntent.destroy_all
    Fabric::Invoice.destroy_all
    Fabric::Charge.destroy_all
  end

  def customer
    @customer ||= Fabric::Customer.create!(
      stripe_id: 'cust_xxx',
      created: Time.now
    )
  end

  def invoice
    @invoice ||= Fabric::Invoice.create!(
      customer: customer,
      customer_id: 'cust_xxx',
      stripe_id: 'invc_xxx'
    )
  end

  def payment_intent
    @payment_intent ||= Fabric::PaymentIntent.create!(
      customer: customer,
      stripe_id: 'pi_xxx',
      invoice: invoice
    )
  end

  def charge
    @charge ||= Fabric::Charge.create!(
      customer: customer,
      invoice_id: 'invc_xxx',
      stripe_id: 'ch_xxx',
      payment_intent: 'pi_xxx'
    )
  end

  def test_payment_intent_and_charge
    payment_intent.reload
    charge.reload
    assert_equal payment_intent.charges.first, charge
    assert_equal charge.payment_intent, payment_intent
  end

  def test_charge_and_invoice
    charge.reload
    invoice.reload
    assert_equal charge.invoice, invoice
    assert_equal invoice.charge, charge
  end

end

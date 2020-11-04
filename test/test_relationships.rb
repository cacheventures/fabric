require 'minitest/autorun'
require 'fabric'
require_relative 'helpers/relationship_helper'

class TestRelationships < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
  end

  def teardown
    Fabric::Customer.destroy_all
    Fabric::PaymentIntent.destroy_all
    Fabric::Invoice.destroy_all
    Fabric::Charge.destroy_all
    Fabric::Dispute.destroy_all
    Fabric::Event.destroy_all
    Fabric::InvoiceItem.destroy_all
    Fabric::PaymentMethod.destroy_all
    Fabric::Subscription.destroy_all
    Fabric::Plan.destroy_all
    Fabric::SubscriptionItem.destroy_all
    Fabric::Price.destroy_all
    Fabric::Product.destroy_all
    Fabric::SetupIntent.destroy_all
    Fabric::Card.destroy_all
    Fabric::UsageRecord.destroy_all
  end

  def test_customer
    customer.reload
    subscription.reload
    card.reload
    invoice.reload
    event.reload
    charge.reload
    invoice_item.reload
    usage_record.reload
    payment_method.reload
    setup_intent.reload
    payment_intent.reload

    assert_equal customer.subscriptions, [subscription]
    assert_equal customer.sources, [card]
    assert_equal customer.invoices, [invoice]
    assert_equal customer.events, [event]
    assert_equal customer.charges, [charge]
    assert_equal customer.invoice_items, [invoice_item]
    assert_equal customer.usage_records, [usage_record]
    assert_equal customer.payment_methods, [payment_method]
    assert_equal customer.setup_intents, [setup_intent]
    assert_equal customer.payment_intents, [payment_intent]
  end

  def test_charge
    charge.reload
    customer.reload
    invoice.reload
    payment_intent.reload

    assert_equal charge.customer, customer
    assert_equal charge.invoice, invoice
    assert_equal charge.payment_intent, payment_intent
  end

  def test_dispute
    dispute.reload
    charge.reload
    payment_intent.reload

    assert_equal dispute.charge, charge
    assert_equal dispute.payment_intent, payment_intent
  end

  def test_event
    event.reload
    customer.reload

    assert_equal event.customer, customer
  end

  def test_invoice
    invoice.reload
    customer.reload
    payment_intent.reload
    charge.reload

    assert_equal invoice.customer, customer
    assert_equal invoice.payment_intent, payment_intent
    assert_equal invoice.charge, charge
  end

  def test_invoice_item
    invoice_item.reload
    customer.reload

    assert_equal invoice_item.customer, customer
  end

  def test_payment_intent
    payment_intent.reload
    customer.reload
    invoice.reload
    charge.reload

    assert_equal payment_intent.customer, customer
    assert_equal payment_intent.invoice, invoice
    assert_equal payment_intent.charges, [charge]
  end

  def test_payment_method
    payment_method.reload
    customer.reload
    subscription.reload

    assert_equal payment_method.customer, customer
    assert_equal payment_method.subscriptions, [subscription]
  end

  def test_plan
    plan.reload
    product.reload
    subscription_item.reload

    assert_equal plan.product, product
    assert_equal plan.subscription_items, [subscription_item]
  end

  def test_price
    price.reload
    product.reload
    subscription_item.reload

    assert_equal price.product, product
    assert_equal price.subscription_items, [subscription_item]
  end

  def test_product
    product.reload
    price.reload
    plan.reload

    assert_equal product.prices, [price]
    assert_equal product.plans, [plan]
  end

  def test_setup_intent
    setup_intent.reload
    customer.reload

    assert_equal setup_intent.customer, customer
  end

  def test_card
    card.reload
    customer.reload

    assert_equal card.customer, customer
  end

  def test_subscription
    subscription.reload
    customer.reload
    subscription_item.reload
    payment_method.reload

    assert_equal subscription.customer, customer
    assert_equal subscription.subscription_items, [subscription_item]
    assert_equal subscription.default_payment_method, payment_method
  end

  def test_subscription_item
    subscription_item.reload
    subscription.reload
    plan.reload
    price.reload
    usage_record.reload

    assert_equal subscription_item.subscription, subscription
    assert_equal subscription_item.plan, plan
    assert_equal subscription_item.price, price
    assert_equal subscription_item.usage_records, [usage_record]
  end

  def test_usage_record
    usage_record.reload
    customer.reload
    subscription_item.reload

    assert_equal usage_record.customer, customer
    assert_equal usage_record.subscription_item, subscription_item
  end

end

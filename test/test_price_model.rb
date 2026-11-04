require 'minitest/autorun'
require 'fabric'

class TestPriceModel < Minitest::Test

  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
    Time.zone = 'UTC'
    @stripe_id = "price_#{SecureRandom.hex(8)}"
  end

  def teardown
    Fabric::Price.where(stripe_id: @stripe_id).delete
  end

  def test_sync_with_stores_decimals_as_stripe_formatted_strings
    tier = {
      flat_amount: nil, flat_amount_decimal: nil, unit_amount: nil,
      unit_amount_decimal: '0.0123', up_to: 10_000
    }
    last_tier = {
      flat_amount: 560_000, flat_amount_decimal: '560000', unit_amount: nil,
      unit_amount_decimal: nil, up_to: nil
    }
    stripe_price = Stripe::Price.construct_from(
      id: @stripe_id,
      object: 'price',
      active: true,
      billing_scheme: 'tiered',
      created: 1_700_000_000,
      currency: 'usd',
      currency_options: {
        eur: {
          tax_behavior: 'unspecified', unit_amount: nil,
          unit_amount_decimal: '1500', tiers: [tier, last_tier]
        }
      },
      custom_unit_amount: nil,
      livemode: false,
      lookup_key: nil,
      metadata: {},
      nickname: nil,
      product: 'prod_xxx',
      recurring: { interval: 'month', interval_count: 1 },
      tax_behavior: 'unspecified',
      tiers: [tier, last_tier],
      tiers_mode: 'volume',
      transform_quantity: nil,
      type: 'recurring',
      unit_amount: nil,
      unit_amount_decimal: '1500'
    )

    price = Fabric::Price.new.sync_with(stripe_price)
    price.save!

    raw = Fabric::Price.collection.find(stripe_id: @stripe_id).first
    assert_equal '1500', raw['unit_amount_decimal']
    assert_equal '0.0123', raw['tiers'][0]['unit_amount_decimal']
    assert_nil raw['tiers'][0]['flat_amount_decimal']
    assert_equal '560000', raw['tiers'][1]['flat_amount_decimal']
    eur = raw['currency_options']['eur']
    assert_equal '1500', eur['unit_amount_decimal']
    assert_equal '0.0123', eur['tiers'][0]['unit_amount_decimal']
    assert_equal '560000', eur['tiers'][1]['flat_amount_decimal']
  end

  def test_handle_decimal
    price = Fabric::Price.new
    assert_equal '560000', price.handle_decimal(BigDecimal('560000'))
    assert_equal '0.0123', price.handle_decimal(BigDecimal('0.0123'))
    assert_equal '-1.5', price.handle_decimal(BigDecimal('-1.5'))
    assert_equal '1500', price.handle_decimal('1500')
    assert_nil price.handle_decimal(nil)
  end

end

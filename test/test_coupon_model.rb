require 'minitest/autorun'
require 'fabric'

class TestCouponModel < Minitest::Test
  def setup
    Mongoid.load!("test/config/mongoid.yml", :test)
  end

  def teardown
    Fabric::Coupon.destroy_all
  end

  def test_coupon_usable_valid_false
    coupon = Fabric::Coupon.create(
      stripe_id: '10off',
      duration: 'forever',
      coupon_valid: false
    )

    refute coupon.usable?
  end

  def test_coupon_usable_redeem_by_passed
    coupon = Fabric::Coupon.create(
      stripe_id: '10off',
      duration: 'forever',
      coupon_valid: true,
      redeem_by: 1.day.ago
    )

    refute coupon.usable?
  end

  def test_coupon_usable_redeem_by_future
    coupon = Fabric::Coupon.create(
      stripe_id: '10off',
      duration: 'forever',
      coupon_valid: true,
      redeem_by: 1.day.from_now
    )

    assert coupon.usable?
  end

  def test_coupon_usable_max_redemptions_exceeded
    coupon = Fabric::Coupon.create(
      stripe_id: '10off',
      duration: 'forever',
      coupon_valid: true,
      times_redeemed: 1,
      max_redemptions: 1
    )

    refute coupon.usable?
  end

  def test_coupon_usable_max_redemptions_not_exceeded
    coupon = Fabric::Coupon.create(
      stripe_id: '10off',
      duration: 'forever',
      coupon_valid: true,
      times_redeemed: 1,
      max_redemptions: 2
    )

    assert coupon.usable?
  end

  def test_coupon_usable_no_restrictions
    coupon = Fabric::Coupon.create(
      stripe_id: '10off',
      duration: 'forever',
      coupon_valid: true,
    )

    assert coupon.usable?
  end

  def test_coupon_valid_for_stripe
    mock_coupon = Minitest::Mock.new
    mock_coupon.expect :is_a?, true, [Stripe::APIResource]
    mock_coupon.expect :valid, true

    assert Fabric::Coupon.new.send(:coupon_valid_for, mock_coupon)
    assert_mock mock_coupon
  end

  def test_coupon_valid_for_document
    mock_coupon = Minitest::Mock.new
    mock_coupon.expect :is_a?, false, [Stripe::APIResource]
    mock_coupon.expect :is_a?, true, [Mongoid::Document]
    mock_coupon.expect :coupon_valid, true

    assert Fabric::Coupon.new.send(:coupon_valid_for, mock_coupon)
    assert_mock mock_coupon
  end

end

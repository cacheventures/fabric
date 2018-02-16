require 'minitest/autorun'
require 'fabric'

# TODO: test config parts
class TestFabricModule < Minitest::Test

  class TestStripeId < TestFabricModule
    def test_stripe_id_for_fail
      assert_raises(Fabric::InvalidResourceError) do
        Fabric.stripe_id_for "string"
      end
    end

    def test_stripe_id_stripe_resource
      mock_customer = Minitest::Mock.new
      mock_customer.expect :is_a?, true, [Stripe::APIResource]
      mock_customer.expect :id, 'cus_0'

      Fabric.stripe_id_for mock_customer
      assert_mock mock_customer
    end

    def test_stripe_id_mongoid_document
      mock_model = Minitest::Mock.new
      mock_model.expect :is_a?, false, [Stripe::APIResource]
      mock_model.expect :is_a?, true, [Mongoid::Document]
      mock_model.expect :stripe_id, 'cus_1'

      Fabric.stripe_id_for mock_model
      assert_mock mock_model
    end
  end

  class TestDefaultPlan < TestFabricModule

    def setup
      Mongoid.load!("test/config/mongoid.yml", :test)
      Fabric::Plan.create(
        stripe_id: '0',
        amount: 1000,
        currency: 'usd',
        interval: 'month',
        created: Time.now,
        name: 'Ten Bucks'
      )
    end

    def teardown
      Fabric::Plan.destroy_all
      ENV.delete('fabric_default_plan')
    end

    def test_default_plan_env
      ENV['fabric_default_plan'] = '0'
      returned = Fabric.default_plan
      assert_equal Fabric::Plan.find_by(stripe_id: '0'), returned
    end

    def test_default_plan_first
      ENV['fabric_default_plan'] = nil
      returned = Fabric.default_plan
      assert_equal Fabric::Plan.find_by(stripe_id: '0'), returned
    end

  end

  class TestGetDocument < TestFabricModule

    def setup
      Mongoid.load!("test/config/mongoid.yml", :test)
      Fabric::Customer.create(stripe_id: 'cus_0', created: Time.now)
    end

    def teardown
      Fabric::Customer.destroy_all
    end

    def test_get_document_model
      model = Fabric::Customer.first
      assert_equal model, Fabric.get_document(Fabric::Customer, model)
    end

    def test_get_document_id
      model = Fabric::Customer.first
      assert_equal model, Fabric.get_document(Fabric::Customer, model.id.to_s)
    end
  end

end

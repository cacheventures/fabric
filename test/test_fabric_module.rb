require 'minitest/autorun'
require 'fabric'

# TODO: test config parts
class TestFabricModule < Minitest::Test

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

require 'minitest/autorun'
require 'fabric'

class TestWebhookModule < Minitest::Test
  include Fabric::Webhook

  class TestCreateEvent < TestWebhookModule

    def setup
      Mongoid.load!("test/config/mongoid.yml", :test)
      Fabric::Customer.create(stripe_id: 'cus_0', created: Time.now)
    end

    def teardown
      Fabric::Event.destroy_all
      Fabric::Customer.destroy_all
    end

    def test_create_event_exists
      event_model = Fabric::Event.create(
        webhook: 'customer.updated',
        stripe_id: 'evt_0',
        customer: Fabric::Customer.first,
        api_version: '1.2.3'
      )
      event_data = {
        'id' => 'evt_0',
        'type' => 'customer.updated',
        'api_version' => '1.2.3',
        'data' => {
          'object' => {
            'object' => 'customer',
            'id' => 'cus_0'
          }
        }
      }
      ret_event, existed = create_event(event_data)
      assert_equal event_model, ret_event
      assert existed
    end

    def test_create_event_doesnt_exist
      event_data = {
        'id' => 'evt_0',
        'type' => 'customer.updated',
        'api_version' => '1.2.3',
        'data' => {
          'object' => {
            'object' => 'customer',
            'id' => 'cus_0'
          }
        }
      }
      ret_event, existed = create_event(event_data)
      saved = ret_event.save

      assert saved
      refute existed
    end

  end

  class TestCheckIdempotence < TestWebhookModule

    def setup
      Mongoid.load!("test/config/mongoid.yml", :test)
      Fabric::Customer.create(stripe_id: 'cus_0', created: Time.now)
    end

    def teardown
      Fabric::Event.destroy_all
      Fabric::Customer.destroy_all
    end

    def test_check_idempotence_exists
      Fabric::Event.create(
        webhook: 'customer.updated',
        stripe_id: 'evt_0',
        customer: Fabric::Customer.first,
        api_version: '1.2.3'
      )
      event_data = {
        'id' => 'evt_0',
        'type' => 'customer.updated',
        'api_version' => '1.2.3',
        'data' => {
          'object' => {
            'object' => 'customer',
            'id' => 'cus_0'
          }
        }
      }
      refute check_idempotence(event_data)
    end

    def test_check_idempotence_doesnt_exist
      event_data = {
        'id' => 'evt_0',
        'type' => 'customer.updated',
        'api_version' => '1.2.3',
        'data' => {
          'object' => {
            'object' => 'customer',
            'id' => 'cus_0'
          }
        }
      }
      assert check_idempotence(event_data)
    end

  end

  class TestHandleMethod < TestWebhookModule

    def test_handle_method
      assert_equal 'method', defined?(handle)
    end

  end

end

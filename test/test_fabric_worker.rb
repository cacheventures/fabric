require 'minitest/autorun'
require 'fabric'

class TestFabricWorker < Minitest::Test

  def setup
    # clean up output from Fabric::Worker
    Fabric.configure do |c|
      c.logger = Logger.new(nil)
    end
  end

  def teardown
    Fabric.configure do |c|
      c.logger = ActiveSupport::Logger.new($stdout)
    end
  end

  def test_perform_calls_operation
    mock = Minitest::Mock.new
    mock.expect :is_a?, false, [Hash]
    mock.expect :to_s, 'tested'

    # added to get worker log line to convert to json properly
    mock.expect :instance_variable_get, nil, [:@delegator]
    mock.expect :instance_variable_get, nil, [:@expected_calls]
    mock.expect :instance_variable_get, nil, [:@actual_calls]
    mock.expect :instance_variable_get, nil, [:@delegator]
    mock.expect :instance_variable_get, nil, [:@expected_calls]
    mock.expect :instance_variable_get, nil, [:@actual_calls]

    Fabric::Worker.new.perform('test_worker', mock)
    assert_mock mock
  end

  def test_perform_calls_callback
    mock = Minitest::Mock.new
    mock.expect :hello, true, [:success]
    Fabric.configure do |c|
      c.worker_callback = Proc.new { |d, t, m| mock.hello(t) }
    end

    Fabric::Worker.new.perform('test_worker', 1, { 'callback' => true })
    assert_mock mock
  end

  def test_perform_does_not_call_callback
    mock = Minitest::Mock.new
    Fabric.configure do |c|
      c.worker_callback = Proc.new { |d, t, m| mock.hello(t) }
    end

    Fabric::Worker.new.perform('test_worker', 1)
    assert_mock mock
  end

  def test_perform_handles_error_with_callback
    mock = Minitest::Mock.new
    mock.expect :uhoh, true, [:error]
    Fabric.configure do |c|
      c.worker_callback = Proc.new { |d, t, m| mock.uhoh(t) }
    end

    Fabric::Worker.new.perform('test_fail_worker', { 'callback' => true })
    assert_mock mock
    # implicit assertion that it didn't raise an error
  end

  def test_perform_handles_error_without_callback
    assert_raises(Stripe::StripeError) do
      Fabric::Worker.new.perform('test_fail_worker')
    end
  end

end

module Fabric
  class TestWorkerOperation
    def initialize(arg)
      @arg = arg
    end
    def call
      @arg.to_s
    end
  end
  class TestFailWorkerOperation
    def call
      fail Stripe::StripeError
    end
  end
end

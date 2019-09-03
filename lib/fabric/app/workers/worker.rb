module Fabric
  class Worker
    include Fabric
    include Sidekiq::Worker

    sidekiq_options queue: 'fabric', retry: false

    def perform(operation, *args)
      @log_data = { class: self.class.name, operation: operation, args: args }
      flogger.json_info 'Started', @log_data

      if args.last.is_a?(Hash) && args.last['callback'] == true
        @callback_data = args.pop
        flogger.json_info 'Found callback data.', @log_data
      end

      klass = "Fabric::#{operation.camelcase}Operation".constantize
      operation = klass.new(*args)
      operation.call

      flogger.json_info 'Success.', @log_data
      call_callback(:success)
    rescue Stripe::StripeError, PaymentIntentError => error
      flogger.json_info 'Error', @log_data.merge!(error: error.inspect)
      call_callback(:error, error) || raise(error)
    end

    def call_callback(type, error = nil)
      return false unless @callback_data.present?
      args = [@callback_data, type]
      data = error.data if error.respond_to?('data')
      args.push(error.message, error.code, data) if error.present?
      Fabric.config.worker_callback.call(*args)
    end

  end
end

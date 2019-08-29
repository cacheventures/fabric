module Fabric
  class Worker
    include Sidekiq::Worker

    sidekiq_options queue: 'fabric', retry: false

    def perform(operation, *args)
      Fabric.config.logger.info "Fabric::Worker: Started with "\
        "#{operation} #{args}"

      if args.last.is_a?(Hash) && args.last['callback'] == true
        @callback_data = args.pop
        Fabric.config.logger.info 'Fabric::Worker: Found callback data.'
      end

      klass = "Fabric::#{operation.camelcase}Operation".constantize
      operation = klass.new(*args)
      operation.call

      Fabric.config.logger.info 'Fabric::Worker: Success.'
      call_callback(:success)
    rescue Stripe::StripeError, PaymentIntentError => error
      Fabric.config.logger.info "Fabric::Worker: Error: #{error.inspect}"
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

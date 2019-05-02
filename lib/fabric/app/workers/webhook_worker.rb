module Fabric
  class WebhookWorker
    include Sidekiq::Worker

    sidekiq_options queue: 'fabric'

    def perform(event, webhook_class)
      log_data = { event: event['id'], webhook_class: webhook_class }
      Fabric.config.logger.info("started #{log_data.to_json}")
      "Fabric::Webhooks::#{webhook_class.camelcase}".constantize.new.call(event)
    end
  end
end

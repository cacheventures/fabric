module Fabric
  module Webhooks
    class SourceDeleted
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        persist_model(event) if Fabric.config.persist?(:source)
        handle(event)
      end

      def persist_model(event)
        source = retrieve_local(:card, event.data.object.id)
        return unless source

        source.destroy
        Fabric.config.logger.info "SourceDeleted: Deleting source: "\
          "#{source.stripe_id}"
      end

    end
  end
end

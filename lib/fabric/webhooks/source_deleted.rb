module Fabric
  module Webhooks
    class SourceDeleted
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist?(:source)

        handle(event)
      end

      def persist_model(event)
        stripe_source = event.data.object
        source = Fabric::Card.find_by(
          stripe_id: stripe_source.id
        )
        if source.present?
          Fabric.config.logger.info "SourceDeleted: Deleting source: "\
            "#{stripe_source.id}"
          source.destroy
        else
          Fabric.config.logger.info "SourceDeleted: Unable to locate "\
            "source: #{stripe_source.id}"
        end
      end

    end
  end
end

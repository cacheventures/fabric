module Fabric
  module Webhooks
    class PlanDeleted
      include Fabric::Webhook

      def call(event)
        if Fabric.config.store_events
          check_idempotency(event) or return
        end

        persist_model(event) if Fabric.config.persist_models

        handle(event)
      end

      def persist_model(event)
        plan = Fabric::Plan.find_by(stripe_id: event.data.object.id)
        unless plan.present?
          Fabric.config.logger.info 'PlanDeleted: Plan not found.'
          return
        end
        plan.destroy
        Fabric.config.logger.info "PlanDeleted: Destroyed plan: "\
          "#{plan.stripe_id}"
      end

    end
  end
end

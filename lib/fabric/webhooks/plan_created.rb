module Fabric
  module Webhooks
    class PlanCreated
      include Fabric::Webhook

      def call(event)
        check_idempotency(event) or return if Fabric.config.store_events
        stripe_plan = retrieve_resource(
          'plan', event['data']['object']['id']
        )
        return if stripe_plan.nil?

        handle(event, stripe_plan)
        persist_model(stripe_plan) if Fabric.config.persist?(:plan)
      end

      def persist_model(stripe_plan)
        plan = Fabric::Plan.new
        plan.sync_with(stripe_plan)
        saved = plan.save
        Fabric.config.logger.info "PlanCreated: Created plan: "\
          "#{plan.stripe_id} saved: #{saved}"
      end
    end
  end
end

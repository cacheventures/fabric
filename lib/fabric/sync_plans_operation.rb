module Fabric
  class SyncPlansOperation
    include Fabric

    def call
      Fabric.config.logger.info "SyncPlansOperation: Fetching all plans and "\
        "syncing with any local copies."
      stripe_plans = Stripe::Plan.all
      stripe_plans.each do |p|
        plan = Fabric::Plan.find_by(stripe_id: p.id) || Fabric::Plan.new
        plan.sync_with(p)
        plan.save
      end
    end
  end
end

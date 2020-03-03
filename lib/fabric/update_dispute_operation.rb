module Fabric
  class UpdateDisputeOperation
    include Fabric

    def initialize(dispute, attributes)
      @log_data = {
        class: self.class.name, dispute: dispute, attributes: attributes
      }
      flogger.json_info 'Started', @log_data
      @dispute = get_document(Dispute, dispute)
      @attributes = attributes
    end

    def call
      stripe_dispute = Stripe::Dispute.update(@dispute.stripe_id, @attributes)

      @dispute.sync_with(stripe_dispute)
      saved = @dispute.save

      flogger.json_info 'Completed', @log_data.merge(saved: saved)

      [@dispute, stripe_dispute]
    end
  end
end

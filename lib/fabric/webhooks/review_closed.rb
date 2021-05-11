module Fabric
  module Webhooks
    class ReviewClosed
      include Fabric::Webhook

      def call(event)
        check_idempotence(event) or return if Fabric.config.store_events
        stripe_review = retrieve_resource(
          'review', event['data']['object']['id']
        )
        return if stripe_review.nil?

        handle(event, stripe_review)
        persist_model(stripe_review) if Fabric.config.persist?(:review)
      end

      def persist_model(stripe_review)
        review = retrieve_local(:review, stripe_review.id)
        return unless review

        review.sync_with(stripe_review)
        saved = review.save

        log_data = {
          class: self.class.name, review: review.stripe_id, saved: saved
        }
        flogger.json_info 'Succeeded', log_data
      end
    end
  end
end

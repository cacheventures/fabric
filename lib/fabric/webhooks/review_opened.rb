module Fabric
  module Webhooks
    class ReviewOpened
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
        review = Review.new
        review.sync_with(stripe_review)
        saved = review.save

        log_data = {
          class: self.class.name, review: review.stripe_id, saved: saved
        }
        flogger.json_info 'Created', log_data
      end
    end
  end
end

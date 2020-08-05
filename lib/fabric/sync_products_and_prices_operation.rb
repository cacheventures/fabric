module Fabric
  class SyncProductsAndPricesOperation
    include Fabric

    def call
      Fabric.config.logger.json_info 'syncing products and prices',
        class: self.class.to_s

      Stripe::Product.list.auto_paging_each do |p|
        product = Fabric::Product.find_by(
          stripe_id: p.id
        ) || Fabric::Product.new
        product.sync_with(p)
        product.save
      end

      Stripe::Price.list(expand: ['data.tiers']).auto_paging_each do |p|
        price = Fabric::Price.find_by(stripe_id: p.id) || Fabric::Price.new
        price.sync_with(p)
        price.save
      end
    end

  end
end

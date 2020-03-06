module Fabric
  class CreateFileOperation
    include Fabric

    def initialize(attributes = {})
      @log_data = { class: self.class.name, attributes: attributes }
      flogger.json_info 'started', @log_data
      @attributes = attributes
    end

    def call
      stripe_file = Stripe::File.create(@attributes)
      file = Fabric::File.new
      file.sync_with(stripe_file)
      saved = file.save

      @log_data[:saved] = saved
      flogger.json_info 'complete', @log_data
      file
    end
  end
end

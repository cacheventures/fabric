module Fabric
  class File
    include Mongoid::Document
    include Mongoid::Timestamps

    field :stripe_id, type: String
    field :purpose, type: String
    field :type, type: String
    field :object, type: String
    field :created, type: Time
    field :filename, type: String
    field :links, type: Hash
    field :size, type: Integer
    field :url, type: String

    def sync_with(file)
      self.stripe_id = file.id
      self.purpose = file.purpose
      self.type = file.type
      self.object = file.object
      self.created = file.created
      self.filename = file.filename
      self.links = file.links&.to_hash&.with_indifferent_access
      self.size = file.size
      self.url = file.url
    end
  end
end

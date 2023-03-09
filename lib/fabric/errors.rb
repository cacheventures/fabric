module Fabric
  class Error < StandardError
    attr_reader :code
    attr_reader :error
    attr_reader :message
    attr_reader :data

    def initialize(message = nil, code: nil, error: nil, data: nil)
      @message = message
      @code = code
      @error = error
      @data = data
    end
  end

  class InvalidResourceError < Error; end
end

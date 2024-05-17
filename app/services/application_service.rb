class ApplicationService
  class << self
    def call(*args, &block)
      new.call(*args, &block)
    end
  end

  def call
    raise NotImplementedError, "You must define `call` as instance method in #{self.class.name} class"
  end
end

class ServiceResponse
  attr_accessor :payload, :errors

  def initialize(payload: nil, errors: [])
    @payload = payload
    @errors = errors
  end

  def fail?
    errors.any?
  end

  def success?
    !fail?
  end
end

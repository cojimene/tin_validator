class ApplicationService
  def self.call(*args, &block)
    new(*args, &block).call
  end

  private :initialize
end
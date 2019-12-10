class StoreCache < SimpleDelegator
  attr_reader :cached

  def initialize(data_store)
    super(data_store)

    @cached = {}
  end

  def fetch(name, *args)
    cached.fetch(name) do
      cached[name] = super
    end
  end
end

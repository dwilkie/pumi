class Pumi::Province < Pumi::Location
  def self.data
    @@provinces ||= from_raw_data(data_set.provinces)
  end
end

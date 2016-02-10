class Address
  include ActiveModel::Model
  attr_accessor :province_id, :district_id, :commune_id, :village_id
end

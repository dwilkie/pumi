class AddressesController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(address_params)
    render(:new)
  end

  private

  def address_params
    params.require(:address).permit(:province_id, :district_id, :commune_id, :village_id)
  end
end

class AddressesController < ApplicationController
  def new
    @address = Address.new
  end

  def create
    @address = Address.new(params[:address])
    render(:new)
  end
end

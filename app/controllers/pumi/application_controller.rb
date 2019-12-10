module Pumi
  class ApplicationController < ActionController::Base
    private

    def permitted_params
      params.permit(:id, :province_id, :district_id, :commune_id, :name_en, :name_km)
    end
  end
end

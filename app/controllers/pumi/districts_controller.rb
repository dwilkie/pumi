module Pumi
  class DistrictsController < ApplicationController
    def index
      render(json: District.where(permitted_params.to_h))
    end
  end
end

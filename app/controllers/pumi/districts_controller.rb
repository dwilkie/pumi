module Pumi
  class DistrictsController < ActionController::Base
    def index
      render(json: District.where(request.query_parameters))
    end
  end
end

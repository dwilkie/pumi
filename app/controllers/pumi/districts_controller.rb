module Pumi
  class DistrictsController < ActionController::Base
    def index
      render(json: ResponseSerializer.new(District.where(request.query_parameters)))
    end
  end
end

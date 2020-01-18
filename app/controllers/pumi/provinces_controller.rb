module Pumi
  class ProvincesController < ActionController::Base
    def index
      render(json: ResponseSerializer.new(Province.where(request.query_parameters)))
    end
  end
end

module Pumi
  class CommunesController < ActionController::Base
    def index
      render(json: ResponseSerializer.new(Commune.where(request.query_parameters)))
    end
  end
end

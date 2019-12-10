module Pumi
  class CommunesController < ActionController::Base
    def index
      render(json: Commune.where(request.query_parameters))
    end
  end
end

module Pumi
  class CommunesController < ApplicationController
    def index
      render(json: Commune.where(permitted_params.to_h))
    end
  end
end

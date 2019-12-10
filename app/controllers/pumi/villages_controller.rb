module Pumi
  class VillagesController < ApplicationController
    def index
      render(json: Village.where(permitted_params.to_h))
    end
  end
end

module Pumi
  class ProvincesController < ApplicationController
    def index
      render(json: Province.where(permitted_params.to_h))
    end
  end
end

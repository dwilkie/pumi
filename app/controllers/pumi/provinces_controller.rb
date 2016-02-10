class Pumi::ProvincesController < Pumi::ApplicationController
  private

  def results
    Pumi::Province.where(params)
  end
end

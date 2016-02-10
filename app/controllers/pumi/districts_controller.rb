class Pumi::DistrictsController < Pumi::ApplicationController
  private

  def results
    Pumi::District.where(params)
  end
end

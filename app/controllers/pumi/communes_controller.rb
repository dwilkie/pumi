class Pumi::CommunesController < Pumi::ApplicationController
  private

  def results
    Pumi::Commune.where(params)
  end
end

class Pumi::VillagesController < Pumi::ApplicationController
  private

  def results
    Pumi::Village.where(params)
  end
end

class Pumi::ApplicationController < ActionController::Base
  def index
    render(:json => results)
  end
end

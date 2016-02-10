Pumi::Engine.routes.draw do
  resources :provinces, :districts, :communes, :villages, :only => :index, :defaults => { :format => :json }
end

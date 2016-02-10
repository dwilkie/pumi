require 'pumi/rails'

Rails.application.routes.draw do
  mount Pumi::Engine => "/pumi"

  resources :addresses, :only => [:new, :create]
end

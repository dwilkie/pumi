module Pumi
  class Engine < ::Rails::Engine
    require "jquery-rails"
    isolate_namespace(Pumi)
  end
end

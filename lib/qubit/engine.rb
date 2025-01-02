module Qubit
  class Engine < ::Rails::Engine
    isolate_namespace Qubit

    initializer "qubit.importmap", before: "importmap" do |app|
      app.config.importmap.paths << root.join("config/importmap.rb")
      # https://github.com/rails/importmap-rails#sweeping-the-cache-in-development-and-test
      app.config.importmap.cache_sweepers << root.join("app/assets/javascripts")
    end

    initializer "qubit.assets" do |app|
      app.config.assets.precompile += %w[qubit_manifest]
    end
  end
end

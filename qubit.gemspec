require_relative "lib/qubit/version"

Gem::Specification.new do |spec|
  spec.name        = "qubit"
  spec.summary     = "A/B Tests on Rails"
  spec.version     = Qubit::VERSION
  spec.authors     = ["James Pettit"]
  spec.email       = ["etherealmachine@gmail.com"]
  spec.license     = "MIT"

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    Dir["{app,config,db,lib}/**/*", "MIT-LICENSE", "Rakefile", "README.md"]
  end

  spec.add_dependency "rails", ">= 7.1.4"
  spec.add_dependency "puma"
  spec.add_dependency "sqlite3"
  spec.add_dependency "sprockets-rails"
  spec.add_dependency "turbo-rails"
end

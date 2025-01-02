source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

# Specify your gem's dependencies in qubit.gemspec.
gemspec

group :development, :test do
  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem "annotate"
end

gem "rails", ">= 7.1.4"
gem "puma"
gem "sqlite3"
gem "sprockets-rails"

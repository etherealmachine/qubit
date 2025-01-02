namespace :qubit do
  desc "Seed the database with Qubit demo data"
  task setup_demo: :environment do
    seed_file = File.expand_path('../../../db/seeds.rb', __FILE__)
    load(seed_file) if File.exist?(seed_file)
  end
end
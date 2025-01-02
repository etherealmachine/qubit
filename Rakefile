require "bundler/setup"

APP_RAKEFILE = File.expand_path("test/dummy/Rakefile", __dir__)
load "rails/tasks/engine.rake"

load "rails/tasks/statistics.rake"

Dir["tasks/*.rake"].each do |task_file|
  load task_file
end

require "bundler/gem_tasks"

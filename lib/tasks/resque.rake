require 'resque/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    ENV['QUEUE'] = '*'
    Resque.redis = 'localhost:6379'
  end
end

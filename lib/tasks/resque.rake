require 'resque/tasks'

namespace :resque do
  task :setup do
    require 'resque'
    ENV['QUEUE'] = '*'
    Resque.redis = ENV.fetch('REDIS_URL') { 'localhost:6379' }
  end
end

Resque.after_fork = Proc.new { ActiveRecord::Base.establish_connection }

require 'yaml'
require 'iron_worker'

@config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "abt", "test", "config.yml")))
IronWorker.configure do |config|
  config.token = @config['iron_worker']['token']
  config.project_id = @config['iron_worker']['project_id']
  config.merge_gem 'minitest', :require=>['minitest/unit', 'minitest/autorun']
end
require 'minitest/autorun'

require_relative '../lib/abt'

@test_config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "iron_mq_ruby", "test", "config.yml")))
worker = Abt::TestWorker.new
worker.git_url = "git://github.com/iron-io/iron_mq_ruby.git"
worker.test_config = @test_config
#worker.run_local
worker.queue
worker.wait_until_complete
puts "LOG:"
puts worker.get_log
#

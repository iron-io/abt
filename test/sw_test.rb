require 'yaml'
require 'iron_worker'

@config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "abt", "test", "config.yml")))
IronWorker.configure do |config|
  config.token = @config['iron_worker']['token']
  config.project_id = @config['iron_worker']['project_id']
end

require_relative '../lib/abt'

@test_config = YAML::load_file(File.expand_path(File.join("~", "Dropbox", "configs", "iron_mq_ruby", "test", "config.yml")))
worker = Abt::AbtWorker.new
worker.git_url = "git://github.com/iron-io/iron_mq_ruby.git"
worker.test_config = @test_config
worker.add_notifier("HipchatNotifier",{"hipchat_api_key"=>'api_key',"room_name"=>'room_name'})
worker.add_notifier("WebHookNotifier","url"=>"http://www.someurl.com")
#worker.run_local
worker.queue
worker.wait_until_complete
puts "LOG:"
puts worker.get_log

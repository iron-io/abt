require 'rest_client'
require 'json'
require 'cgi'
require 'yaml'

ARGV=params['parameters']||[] # this needs to stay here or else it won't run the correct tests


require 'minitest/unit'
require 'minitest/autorun'
require 'test/unit/priority'
require 'test/unit/testcase'
require 'test/unit/assertions'
require 'test/unit'
require 'git'
require 'bundler'
require 'lib/test_collector'
require 'lib/test_helper'
Dir[File.dirname(__FILE__) + '/notifiers/*.rb'].each { |file| require file }

puts "Params:#{params.inspect}"
puts "Payload:#{payload.inspect}"
clone_dir = 'cloned'
x         = File.join('.', clone_dir)
p x
$abt_config = params['test_config']

yaml_config = YAML.load_file('config.yml') if File.exist? 'config.yml'
config = yaml_config|| { }
puts "Config from file:#{config.inspect}"
if payload
  puts "Got payload from webhook!"
  cgi_parsed = CGI::parse(payload)
  puts "cgi_parsed: #{cgi_parsed.inspect}"
# Then we can parse the json
  if cgi_parsed['payload'] && cgi_parsed['payload'][0]
    parsed = JSON.parse(cgi_parsed['payload'][0])
    puts "parsed: #{parsed.inspect}"
    config['git_url'] = parsed["repository"]["url"] if parsed["repository"] && parsed["repository"]["url"]
  end
end
config.merge! params
puts "Merged config:#{config.inspect}"
raise "No git url found!" unless config['git_url']
puts "cloning #{config['git_url']}..."
Git.clone(config['git_url'], clone_dir, :path => '.')
old_specs       = nil
test_gemfile    = File.join(File.expand_path(clone_dir+'/test'), 'Gemfile')
root_gemfile    = File.join(File.expand_path(clone_dir), 'Gemfile')
current_gemfile = File.exist?(test_gemfile) ? test_gemfile : root_gemfile
puts "GEMFILE:#{current_gemfile}"
puts "DIR:#{File.join(clone_dir+'/test')}"
puts "#{Dir.glob('*').inspect}"
if File.exist?(current_gemfile)
  puts "Bundling gems"
  system "cd #{File.join(clone_dir+'/test')}; bundle install --deployment"
  puts "Gemfile:#{current_gemfile}"
  old_specs = Gem.loaded_specs.dup
  Gem.loaded_specs.clear
  ENV['BUNDLE_GEMFILE'] = current_gemfile
  puts "Bundling!"
  require 'bundler/setup'
  puts "List of gems from Gemfile: #{Gem.loaded_specs.inspect}"
end
Dir.glob(File.join('.', clone_dir, 'test', 'test_*')).each { |f|
  puts "requiring #{f}"
  require f
}

Test::Unit::Notify::Notifier.add_params({ :notify_every => params['notify_every'] }) if config['notify_every']
if config['notifiers']
  config['notifiers'].each do |notifier|
    puts "NOTIFIER:#{notifier.inspect}"
    notifier["config"].merge!({ "task_id" => iron_task_id, "git_url" => config['git_url'] }) if notifier["config"]
    Test::Unit::Notify::Notifier.add_notifier(Kernel.const_get(notifier["class_name"]).new(notifier["config"] || { }))
  end
end
puts 'Starting autorunner'
Test::Unit::AutoRunner.run
puts 'Autorunner finished'

if old_specs
  Gem.loaded_specs.clear
  old_specs.each do |k, v|
    puts "Loading gem:#{k}"
    Gem.loaded_specs[k]=v
  end
  puts "Full list of gems: #{Gem.loaded_specs.inspect}"
end

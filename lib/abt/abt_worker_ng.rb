require 'rest_client'
ARGV=[] # this needs to stay here or else it won't run the correct tests


require 'minitest/unit'
require 'minitest/autorun'
require 'test/unit/priority'
require 'test/unit/testcase'
require 'test/unit/assertions'
require 'test/unit'
require 'git'
require 'bundler'


require File.dirname(__FILE__) + '/test_collector.rb'
Dir[File.dirname(__FILE__) + '/notifiers/*.rb'].each { |file| require file }
clone_dir = 'cloned'
x = File.join('.', clone_dir)
p x
$abt_config = params['test_config']

puts "cloning #{params['git_url']}..."
Git.clone(params['git_url'], clone_dir, :path => '.')
old_specs = nil
current_gemfile = File.join(File.expand_path(clone_dir+'/test'), 'Gemfile')
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

Test::Unit::Notify::Notifier.add_params({:notify_every => params['notify_every']}) if params['notify_every']
if params['notifiers']
  params['notifiers'].each do |notifier|
    puts "NOTIFIER:#{notifier.inspect}"
    Test::Unit::Notify::Notifier.add_notifier(Kernel.const_get(notifier["class_name"]).new(notifier["config"]))
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

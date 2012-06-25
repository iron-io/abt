require 'iron_worker'
require 'json'

# bump.
ARGV=[] # this needs to stay here or else it won't run the correct tests
module Abt

  @@notifiers = {}
  @@notifiers[:hip_chat_notifier] = {:file=>'notifiers/hip_chat_notifier', :class_name=>'HipChatNotifier'}

  def self.notifiers
    @@notifiers
  end

  class AbtWorker < IronWorker::Base
    merge_gem 'minitest', :require=>['minitest/unit', 'minitest/autorun']
    merge_gem 'test-unit', :require=>['test/unit/priority', 'test/unit/testcase', 'test/unit/assertions', 'test/unit']
    merge_gem 'git'
    merge_gem 'bundler'
    merge 'test_collector'
    #merge_folder 'notifiers'
    attr_accessor :git_url, :test_config, :notifiers, :notify_every

    def initialize
      @notifiers = []
    end

    def add_notifier(notifier_class, notifier_details={})
      p notifier_class
      p notifier_details
      notifier_entry = {}
      if notifier_class.instance_of?(Symbol)
        p Abt.notifiers
        n = Abt.notifiers[notifier_class]
        puts "n=" + n.inspect
        raise "Notifier not found: #{notifier_class}" if n.nil?
        self.class.merge n[:file]
        notifier_entry["class_name"] = n[:class_name]
        notifier_entry["config"] = notifier_details[:config]
      else
        self.class.merge notifier_class
        raise "Must include :class option" if notifier_details[:class_name].nil?
        notifier_entry["class_name"] = notifier_details[:class_name]
        notifier_entry["config"] = notifier_details[:config]
      end
      notifier_entry["config"].merge!({"git_url"=>@git_url}) if notifier_entry["config"]
      @notifiers << notifier_entry
    end

    def run
      if is_remote?
        require File.join(File.dirname(__FILE__), '/gems/minitest/lib/minitest/unit')
        require File.join(File.dirname(__FILE__), '/gems/test-unit/lib/test/unit/priority')
        require File.join(File.dirname(__FILE__), '/gems/test-unit/lib/test/unit/testcase')
        require File.join(File.dirname(__FILE__), '/gems/test-unit/lib/test/unit/assertions')
        require File.join(File.dirname(__FILE__), '/gems/test-unit/lib/test/unit')
        require File.join(File.dirname(__FILE__), '/gems/minitest/lib/minitest/autorun')
      end
      clone_dir = 'cloned'
      x = File.join(user_dir, clone_dir)
      p x
      if is_local?
        FileUtils.rm_rf(File.join(user_dir, clone_dir))
      end

      $abt_config = self.test_config

      puts "cloning #{git_url}..."
      g = Git.clone(git_url, clone_dir, :path => user_dir)
      old_specs = nil

      test_gemfile = File.join(File.expand_path(user_dir+clone_dir+'/test'), 'Gemfile')
      root_gemfile = File.join(File.expand_path(user_dir+clone_dir), 'Gemfile')
      current_gemfile = File.exist?(test_gemfile) ? test_gemfile : root_gemfile

      log "GEMFILE:#{current_gemfile}"
      log "DIR:#{File.join(user_dir+clone_dir+'/test')}"
      if File.exist?(current_gemfile)
        log "Bundling gems"
        system "cd #{File.join(user_dir+clone_dir+'/test')}; bundle install --deployment"
        log "Gemfile:#{current_gemfile}"
        old_specs = Gem.loaded_specs.dup
        Gem.loaded_specs.clear
        ENV['BUNDLE_GEMFILE'] = current_gemfile
        log "Bundling!"
        require 'bundler/setup'
        log "List of gems from Gemfile: #{Gem.loaded_specs.inspect}"
      end
      Dir.glob(File.join(user_dir, clone_dir, 'test', 'test_*')).each { |f|
        puts "requiring #{f}"
        require f
      }

      Test::Unit::Notify::Notifier.add_params({:notify_every=>notify_every}) if notify_every
      if notifiers
        notifiers.each do |notifier|
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
          log "Loading gem:#{k}"
          Gem.loaded_specs[k]=v
        end
        log "Full list of gems: #{Gem.loaded_specs.inspect}"
      end

    end

  end

end

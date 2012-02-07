require 'iron_worker'
require 'json'
# bump.....
ARGV=[]
module Abt
  #
  #class MiniTestWithHooks < MiniTest::Unit
  #  def before_suites
  #  end
  #
  #  def after_suites
  #  end
  #
  #  def _run_suites(suites, type)
  #    puts 'run_suites ' + suites.inspect + ' type=' + type.inspect
  #    begin
  #      before_suites
  #      super(suites, type)
  #    ensure
  #      after_suites
  #    end
  #  end
  #
  #
  #
  #  def _run_suite(suite, type)
  #    puts 'run_suite ' + suite.inspect + ' type=' + type.inspect
  #    begin
  #      # suite.before_suite
  #      super(suite, type)
  #    ensure
  #      # suite.after_suite
  #    end
  #  end
  #end
  #
  #..
  class AbtWorker < IronWorker::Base
    merge_gem 'minitest', :require=>['minitest/unit', 'minitest/autorun']
    merge_gem 'test-unit', :require=>['test/unit/priority', 'test/unit/testcase', 'test/unit/assertions', 'test/unit']
    merge_gem 'git'
    merge_gem 'hipchat-api'
    merge_gem 'bundler'
    merge 'test_collector'
    merge_folder 'notifiers'
    attr_accessor :git_url, :test_config, :notifiers, :notify_every

    def add_notifier(notifier_name, notifier_details={})
      @notifiers||=[]
      @notifiers<<{"notifier_name"=>notifier_name, "notifier_details"=>notifier_details}
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
        # Test::Unit.run = false
        #MiniTest::Unit.runner = MiniTestWithHooks.new
        # g = Git.open(user_dir, :log => Logger.new(STDOUT))
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
      current_gemfile = File.join(File.expand_path(user_dir+clone_dir+'/test'), 'Gemfile')
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
          Test::Unit::Notify::Notifier.add_notifier(Kernel.const_get(notifier["notifier_name"]).new(notifier["notifier_details"]))
        end
      end
      Test::Unit::AutoRunner.run

      if old_specs
        Gem.loaded_specs.clear
        old_specs.each do |k, v|
          log "Loading gem:#{k}"
          Gem.loaded_specs[k]=v
        end
        log "Full list of gems: #{Gem.loaded_specs.inspect}"
      end

    end
    # ...
    #  def suite_results_output(options={})
    #    line_break = "\n"
    #    if options[:format] == 'html'
    #      line_break = "<br/>"
    #    end
    #    s = "Suite Results:#{line_break}"
    #    s << "#{@num_failed} failed out of #{@num_tests} tests.#{line_break}"
    #    if @num_failed > 0
    #      @failed.each do |f|
    #        s << "#{f.test_class}.#{f.test_method} failed: #{f.result.message}#{line_break}"
    #      end
    #    end
    #    s << "Test suite duration: #{duration}ms.#{line_break}"
    #    s
    #  end
    #
    #  def duration
    #    ((@end_time.to_f - @start_time.to_f) * 1000.0).to_i
    #  end
    #
    #  def time_in_ms(t)
    #    (t.to_f * 1000.0).to_i
    #  end
    #
    #  # callbacks
    #  def on_complete
    #
    #  end
    #
  end

end

# Always Be Testing!!!

A test suite that uses IronWorker by http://www.iron.io to run it.

## Getting Started

First of all the, code to test must be able to check for a special config variable:

    if defined? $abt_config
      @config = $abt_config
    end

A real world example is here: https://github.com/iron-io/iron_mq_ruby/blob/master/test/test_base.rb

Get it running locally first, here's an example:

    worker = Abt::TestWorker.new
    worker.git_url = "git://github.com/iron-io/iron_mq_ruby.git"
    worker.test_config = @test_config
    worker.run_local

Add built in notifier:

    worker.add_notifier(:hip_chat_notifier, :config=>{"hipchat_api_key"=>'secret_api_key', "room_name"=>'Room Name', "user_name"=>"AbtWorker"})

you can add as many notifiers as you need and even make your own (read down for how to build custom notifiers).

Then try queuing it up.

    worker.queue

If that works all good, then:

## Schedule It!

Schedule it to run regularly to ensure you're always being covered.

    worker.schedule(:start_at=>Time.now, :run_every=>3600)

## Custom notifiers

Here's how to build your own notifiers.

* Implement in your notifier the following methods:

setup configuration:

    def initialize(config)
      @url = config["url"]
    end

process simple text message

    def send_message(message)
      puts message
    end

if you want more detailed results, 'result' is an instance of Test::Unit::TestResult

    def send_formatted_message(result)
     result.inspect
    end

Then to use it:

    worker.add_notifier(File.join(File.dirname(__FILE__), 'console_notifier'), :class_name=>'ConsoleNotifier', :config={})

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

Add notifier

    worker.add_notifier("HipchatNotifier",{"hipchat_api_key"=>'secret_api_key',"room_name"=>'Room Name',"title"=>"From"})
and/or
    worker.add_notifier("WebHookNotifier",{"url"=>'notification_url'})
you could add as many notifiers as you need

Then try queuing it up.

    worker.queue

If that works all good, then:

## Schedule It!

Schedule it to run regularly to ensure you're always being covered.

    worker.schedule(:start_at=>Time.now, :run_every=>3600)

## Custom notifiers

###All you need:

* Implement in your notifier following methods:

setup configuration:

    def initialize(notifier_details)
      @url = notifier_details["url"]
    end

process simple text message

    def send_message(message)
      puts message
    end

if you need you could process more detailed results, 'result' is an instance of Test::Unit::TestResult

    def send_formatted_message(result)
     result.inspect
    end


* Add your custom notifier into 'notifiers' folder or just merge it
* Add your notifier to worker
    worker.add_notifier("YourCustomNotifierClass",{"option_name"=>'option_value'})
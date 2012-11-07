# Always Be Testing!!!

A test framework that uses [IronWorker](http://www.iron.io) to run it... constantly.

Read this blog post for background: [When Unit Tests Aren't Enough... ABT - Always Be Testing](http://blog.iron.io/2012/02/when-unit-tests-arent-enough-abt-always.html).

## Getting Started

First of all, the code to test must be able to check for a special config variable:

    if defined? $abt_config
      @config = $abt_config
    end

A real world example of using $abt_config is here: https://github.com/iron-io/iron_mq_ruby/blob/master/test/test_base.rb

### Upload worker

    iron_worker upload https://github.com/iron-io/abt/blob/master/abt.worker

Or (if you want to customize smth)

    git clone https://github.com/iron-io/abt.git
    iron_worker upload abt

### Get it running

  Using CLI

    iron_worker queue abt -p "{\"git_url\":\"git://github.com/iron-io/iron_mq_ruby.git\",\"test_config\":{}}"

  Using code(check queue.rb):

    require 'iron_worker_ng'
    client = IronWorkerNG::Client.new(:token => 'TOKEN', :project_id => 'PROJECT_ID')
    params = {
          "git_url" => 'git://github.com/iron-io/iron_mq_ruby.git',
          "parameters" => ['--name=/test_performance.*/'],
          "test_config" => {}}

    client.tasks.create('abt', params)

### Add built in notifier (optional):

  Using CLI

    iron_worker queue abt -p "{\"notifiers\":[{\"class_name\":\"HipChatNotifier\", \"config\":{\"token\":\"HIPCHAT_TOKEN\", \"room_name\":\"AlwaysBeTesting\", \"important_room_name\":\"RoomName\", \"user_name\":\"ABT Worker\"}}], \"git_url\":\"git://github.com/iron-io/iron_worker_ruby.git\", \"test_config\":{}}}"

Using code(check queue.rb):

    params.merge! {"notifiers" => [{"class_name"=>"HipChatNotifier",
                               "config"=>{"token"=>"HIPCHAT_TOKEN",
                                          "room_name"=>"AlwaysBeTesting",
                                          "important_room_name"=>"RoomName",
                                          "user_name"=>"ABT",
                                          "git_url"=>"git://github.com/SAMPLE.git"}},
                              ]}

you can add as many notifiers as you need and even make your own (read down for how to build custom notifiers).


## Schedule It!

Schedule it to run regularly to ensure you're always being covered.

Using CLI

    iron_worker schedule --start-at "2013-01-01T00:00:00-04:00" --run-every 600 --payload  "{\"git_url\":\"git://github.com/iron-io/iron_mq_ruby.git\",\"test_config\":{}}"

Using code

    client.schedules.create('abt', params, {:start_at => Time.now,:run_every=>600})

## Custom notifiers

Here's how to build your own notifiers.

Implement in your notifier the following methods:

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

## Custom unit-test command line options

filter test methods by pattern:

    "parameters" => ['--name=/test_performance.*/']

## Webhooks

* git clone https://github.com/iron-io/abt.git
* Change parameters in config.yml
* iron_worker upload abt
* Configure Github (or any other) webhook ie: https://worker-aws-us-east-1.iron.io/2/projects/{PROJECT_ID}/tasks/webhook?oauth={TOKEN}&code_name=abt


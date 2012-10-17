# Always Be Testing!!!

A test framework that uses [IronWorker](http://www.iron.io) to run it... constantly. 

Read this blog post for background: [When Unit Tests Aren't Enough... ABT - Always Be Testing](http://blog.iron.io/2012/02/when-unit-tests-arent-enough-abt-always.html).

## Getting Started

First of all, the code to test must be able to check for a special config variable:

    if defined? $abt_config
      @config = $abt_config
    end

A real world example of using $abt_config is here: https://github.com/iron-io/iron_mq_ruby/blob/master/test/test_base.rb

### Install Gem

    sudo gem install abt

### Get it running locally first, here's an example:


 Upload worker from console:

    iron_worker upload abt

 Create worker:

    require 'iron_worker_ng'
    client = IronWorkerNG::Client.new(:token => 'TOKEN', :project_id => 'PROJECT_ID')
    params = {
          "git_url" => 'git://github.com/iron-io/iron_mq_ruby.git',
          "parameters" => ['--name=/test_performance.*/'],
          "test_config" => {TESTCONFIG}

### Add built in notifier (optional):

    params.merge! {"notifiers" => [{"class_name"=>"HipChatNotifier",
                               "config"=>{"token"=>"HIPCHAT_TOKEN",
                                          "room_name"=>"AlwaysBeTesting",
                                          "important_room_name"=>"RoomName",
                                          "user_name"=>"ABT",
                                          "git_url"=>"git://github.com/SAMPLE.git"}},
                              ]}


you can add as many notifiers as you need and even make your own (read down for how to build custom notifiers).

### Then try queuing it up.

    client.tasks.create('AbtWorker', params)

If that works all good, then:

## Schedule It!

Schedule it to run regularly to ensure you're always being covered.

    client.schedules.create('AbtWorker', params, {:start_at => Time.now,:run_every=>600})

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


## Custom unit-test command line options

filter all test methods by pattern:
    "parameters" => ['--name=/test_performance.*/']

### Webhooks
* Setup parameters in config.yml (in lib/abt dir)
* Upload abt worker
* Configure Github (or any other) webhook ie: https://worker-aws-us-east-1.iron.io/2/projects/{PROJECT_ID}/tasks/webhook?oauth={TOKEN}&code_name=AbtWorker



##Obsolete iron_worker version

### Get it running locally first, here's an example:

    require 'abt'
    worker = Abt::AbtWorker.new
    worker.git_url = "git://github.com/iron-io/iron_mq_ruby.git"
    # test_config will be exactly what your library will find at $abt_config
    worker.test_config = @test_config
    worker.run_local

### Add built in notifier (optional):

    worker.add_notifier(:hip_chat_notifier, :config=>{"hipchat_api_key"=>'secret_api_key', "room_name"=>'Room Name',"important_room_name"=>'SecondRoom Name', "user_name"=>"AbtWorker"})

### Then try queuing it up.

    worker.queue

If that works all good, then:

## Schedule It!

Schedule it to run regularly to ensure you're always being covered.

    worker.schedule(:start_at=>Time.now, :run_every=>3600)

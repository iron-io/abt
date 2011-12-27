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

Then try queuing it up.

    worker.queue

If that works all good, then:

## Schedule It!

Schedule it to run regularly to ensure you're always being covered.

    worker.schedule(:start_at=>Time.now, :run_every=>3600)


require 'test/unit/autorunner'
require 'test/unit'

module Test
  module Unit
    AutoRunner.prepare do |auto_runner|
      Notify.setup_auto_runner(auto_runner)
    end

    AutoRunner.setup_option do |auto_runner|
      Notify.setup_auto_runner(auto_runner)
    end

    module Notify
      class << self
        def setup_auto_runner(auto_runner) # :nodoc:
          auto_runner.listeners.reject! do |listener|
            listener.is_a?(Notify::Notifier)
          end
          auto_runner.listeners << Notifier.new
        end
      end

      class Notifier
        def self.set_notifier(sender)
          @sender=sender
          puts "Setting sender!#{@sender.inspect}"
          end
        def self.get_notifier
          @sender
        end

        def attach_to_mediator(mediator)
          mediator.add_listener(UI::TestRunnerMediator::STARTED,
                                &method(:started))
          mediator.add_listener(UI::TestRunnerMediator::FINISHED,
                                &method(:finished))
        end

        def started(result)
          @result = result
        end

        def finished(elapsed_time)

          message = "Status:%s [%g%%] (%gs)" % [@result.status,
                                              @result.pass_percentage,
                                              elapsed_time]
          puts "Message:#{message}:"
          puts "TEST_RESULT:#{@result.inspect}"
          sender = Notifier.get_notifier
          sender.send_message(message) if sender
        end

      end

      class HipchatNotifier
        require 'hipchat-api'
        def initialize(hipchat_api_key, room_name)
          @client = HipChat::API.new(hipchat_api_key)
          @room_name = room_name
        end

        def send_message(message)
          puts "sending_message #{message}"
          puts @client.rooms_message(@room_name, 'IronWorker', message, false).body
        end
      end
    end
  end
end
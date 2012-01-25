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

        def self.add_params(params={})
          @params||={}
          @params.merge!(params)
        end

        def self.get_params
          @params||{}
        end

        def self.add_notifier(sender)
          @senders||=[]
          @senders<<sender
          puts "adding sender!#{@senders.inspect}"
        end

        def self.get_notifiers
          @senders||[]
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

        def notify?(params,result)
          return true unless result.passed?
          if params && params[:notify_every]
            ((Time.now.hour % params[:notify_every].to_i == 0) && Time.now.min > 0 && Time.now.min < 10)
          else
            true
          end
        end

        def finished(elapsed_time)
          message = "Status:%s [%g%%] (%gs)" % [@result.status,
                                                @result.pass_percentage,
                                                elapsed_time]
          puts "Message:#{message}:"
          puts "TEST_RESULT:#{@result.inspect}"
          params = Notifier.get_params
          senders = Notifier.get_notifiers
          senders.each do |sender|
            puts "sender:#{sender.inspect}"
            puts "Notify?:#{notify?(params,@result).inspect}"
            if sender && notify?(params,@result)
              if sender.respond_to?(:send_formatted_message)
                puts sender.send_formatted_message(@result)
              elsif sender.respond_to?(:send_message)
                puts sender.send_message(message)
              end
            end
          end
        end

      end
    end
  end
end
class HipchatNotifier
  require 'hipchat-api'

  def initialize(notifier_details)
    @client = HipChat::API.new(notifier_details["hipchat_api_key"])
    @room_name = notifier_details["room_name"]
  end

  def send_message(message)
    puts "sending_message #{message}"
    begin
      puts @client.rooms_message(@room_name, 'IronWorker', message, false).body
    rescue =>ex
      ex.inspect
    end
  end
end
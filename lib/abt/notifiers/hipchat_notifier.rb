class HipchatNotifier
  require 'hipchat-api'

  def initialize(notifier_details)
    @client = HipChat::API.new(notifier_details["hipchat_api_key"])
    @room_name = notifier_details["room_name"]
    @title= notifier_details["title"]
  end

  def send_formatted_message(result)
    color = result.passed? ? 'green' : 'red'
    message = "Result: <b>#{result.status}</b> [#{result.pass_percentage}%] <br>
     <strong>#{result.run_count}</strong> tests, <strong>#{result.assertion_count}</strong> assertions"
    if result.error_occurred? || result.failure_occurred?
     message+=", <strong>#{result.failure_count}</strong> failures, <strong>#{result.error_count}</strong>, errors<br/>"
      result.faults.each { |f| message+="<br><pre>#{f.to_s.gsub(/>/,' ').gsub(/</,' ')}</pre><br/>" }
     end
    send_message(message,color)
  end

  def send_message(message,color='yellow')
    puts "sending_message #{message}"
    begin
      puts @client.rooms_message(@room_name, @title, message, false,color).body
    rescue =>ex
      ex.inspect
    end
  end
end
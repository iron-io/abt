class WebHookNotifier
  require 'rest-client'

  def initialize(notifier_details)
    @url = notifier_details["url"]
  end

  def send_message(message)
    puts "sending_message #{message}"
    post(message)
  end

  def post(message)
    begin
      RestClient.post(@url, {:message=>message}, headers)
    rescue RestClient::Exception => ex
      ex.inspect
    end
  end

  def headers
    #coudl be added oauth token
    {'User-Agent' => "ABT Ruby Client"}
  end


end
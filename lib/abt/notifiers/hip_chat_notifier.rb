class HipChatNotifier
  IronWorker.config.merge_gem 'hipchat-api'
  require 'hipchat-api'

  def initialize(config)
    @client = HipChat::API.new(config["token"])
    @room_name = config["room_name"]
    @user_name = config["user_name"] || "AbtWorker"
    @git_url = config["git_url"]
  end

  def send_formatted_message(params)
    result = params[:result]
    color = result.passed? ? 'green' : 'red'
    message = "URL: #{@git_url} Result: <b>#{result.status}</b> [#{result.pass_percentage}%] (#{params[:elapsed_time]} sec)<br>
     <strong>#{result.run_count}</strong> tests, <strong>#{result.assertion_count}</strong> assertions"
    if result.error_occurred? || result.failure_occurred?
      message+=", <strong>#{result.failure_count}</strong> failures, <strong>#{result.error_count}</strong>, errors<br/>"
      result.faults.each { |f| message+="<br><pre>#{add_github_urls(f.to_s.gsub(/>/, ' ').gsub(/</, ' '))}</pre><br/>" }
    end
    send_message(message, color)
  end

  def add_github_urls(message)
    url = @git_url.gsub!(/git:/, 'https:').gsub!(/\.git/, '')
    pass = message.gsub(/\/cloned\/(lib\/.+?):(\d+):/,
                        "<a href='#{url}" +
                            "/blob/master" +
                            '/\1#L\2'+"'"+'>\0</a>')


    pass.gsub(/\/cloned\/(test\/[^vendor].+?):(\d+):/,
              "<a href='#{url}" +
                  "/blob/master" +
                  '/\1#L\2'+"'"+'>\0</a>')
  end

  def send_message(message, color='yellow')
    puts "sending_message #{message}"
    begin
      puts @client.rooms_message(@room_name, @user_name, message, false,color).body
    rescue => ex
      ex.inspect
    end
  end
end

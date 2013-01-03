class HipChatNotifier
  IronWorker.config.merge_gem 'hipchat-api' if defined? IronWorker
  require 'hipchat-api'

  MAX_HIPCHAT_MSG_LENGTH = 10000

  def initialize(config)
    @client = HipChat::API.new(config["token"])
    @room_name = config["room_name"]
    @important_room_name = config["important_room_name"]
    @user_name = config["user_name"] || "AbtWorker"
    @git_url = config["git_url"]
    @iw_details ={:task_id=>config["task_id"],:project_id=>config["project_id"]} if config["task_id"] && config["project_id"]
  end

  def send_formatted_message(params)
    result = params[:result]
    color = result.passed? ? 'green' : 'red'
    message = "Result: <b>#{result.status}</b> [#{result.pass_percentage}%] (#{params[:elapsed_time]} sec)<br>
     <strong>#{result.run_count}</strong> tests, <strong>#{result.assertion_count}</strong> assertions, <strong>#{result.faults.size}</strong> faults"
    important_room_failure_message = message
    message+="<br/><b>Tests benchmarks</b>: <br/>" + format_benchmarks(params[:test_benchmarks]) if params[:test_benchmarks]
    
    if result.error_occurred? || result.failure_occurred?
      message+=", <strong>#{result.failure_count}</strong> failures, <strong>#{result.error_count}</strong>, errors<br/>"
      result.faults.each { |f| message+="<br><pre>#{add_github_urls(f.to_s.gsub(/>/, ' ').gsub(/</, ' '))}</pre><br/>" }
    end
    git_url = "<br/>URL: <b>#{@git_url}</b> "
    message += git_url
    important_room_failure_message += git_url

    hud_url = "<br/>HUD (log): <a href='#{hud_log_url(@iw_details)}'>#{@iw_details[:task_id]}</a> " if @iw_details
    message += hud_url
    important_room_failure_message += hud_url

    if message.size() > MAX_HIPCHAT_MSG_LENGTH
      message = important_room_failure_message
    end
    send_message(@room_name, message, color)
    send_message(@important_room_name, important_room_failure_message, color,true) unless result.passed?
  end


  def hud_log_url(details)
    "http://hud.iron.io/tq/projects/#{details[:project_id]}/jobs/#{details[:task_id]}/log"
  end

  def format_benchmarks(test_benchmarks)
    test_benchmarks.map {|k,v| "#{k} -  #{v.round(2)}sec"}.join('<br/>')
  end

  def add_github_urls(message)
    return message unless @git_url
    puts "GIT_URL:#{@git_url}"
    url = @git_url.gsub(/git:/, 'https:').gsub(/\.git/, '')
    pass = message.gsub(/\/cloned\/(lib\/.+?):(\d+):/,
                        "<a href='#{url}" +
                            "/blob/master" +
                            '/\1#L\2'+"'"+'>\0</a>')


    pass.gsub(/\/cloned\/(test\/[^vendor].+?):(\d+):/,
              "<a href='#{url}" +
                  "/blob/master" +
                  '/\1#L\2'+"'"+'>\0</a>')
  end

  def send_message(room_name,message, color='yellow',notify=false)
    puts "sending_message #{message}"
    begin
      puts @client.rooms_message(room_name, @user_name, message, notify,color).body
    rescue => ex
      puts ex.inspect
    end
  end
end

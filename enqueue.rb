require 'iron_worker_ng'
client = IronWorkerNG::Client.new

params = {
    "git_url" => 'git://github.com/iron-io/iron_mq_ruby.git',
    "test_config" => {"iron" =>
                          {"project_id" => "YOUR_PROJECT_ID",
                           "token" => "YOUR_TOKEN"}
    },
    "notifiers" => [
        {"class_name" => "HipChatNotifier",
         "config" => {"token" => "HIPCHAT_TOKEN",
                      "room_name" => "AlwaysBeTesting",
                      "important_room_name" => "RoomName",
                      "user_name" => "AbtWorker"}
        },
    ]
}

p client.tasks.create('abt', params)


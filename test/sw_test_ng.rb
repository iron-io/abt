require 'iron_worker_ng'
client = IronWorkerNG::Client.new(:token => 'ZJI9lH', :project_id => '4f461')


params = {"notifiers" => [{"class_name"=>"HipChatNotifier",
                           "config"=>{"token"=>"c71bf222ac8",
                                      "room_name"=>"AlwaysBeTesting",
                                      "important_room_name"=>"RoomName",
                                      "user_name"=>"ABT MQ Staging",
                                      "git_url"=>"git://github.com/iron-io/iron_worker_ruby.git"}},
                          ],
      "git_url" => 'git://github.com/iron-io/iron_worker_ruby.git',
      "test_config" => {"iron"=>
                            {"host"=>"stagin",
                             "project_id"=>"4ad",
                             "token"=>"dPMijkasdasd"},
                        "count"=>100}}

client.tasks.create('AbtWorker', params)
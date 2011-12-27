require 'rake/dsl_definition' # temporary I think?
require 'rake/testtask'
require 'jeweler2'

Jeweler::Tasks.new do |gemspec|
  gemspec.name = "abt"
  gemspec.summary = "Always Be Testing Yo! A testing framework that runs on IronWorker http://www.iron.io"
  gemspec.description = "Always Be Testing Yo! A testing framework that runs on IronWorker http://www.iron.io"
  gemspec.email = "travis@iron.io"
  gemspec.homepage = "https://github.com/iron-io/abt"
  gemspec.authors = ["Travis Reeder"]
  gemspec.files = FileList['lib/**/*.rb', 'VERSION.yml']
  gemspec.add_dependency 'git'
  gemspec.add_dependency 'iron_worker'
  # gemspec.add_dependency 'rest-client'
  #gemspec.add_dependency 'typhoeus'
  gemspec.required_ruby_version = '>= 1.9'
end
Jeweler::GemcutterTasks.new

Rake::TestTask.new do |t|
  t.libs << "test"
  t.test_files = FileList['test/test*.rb']
  t.verbose = true
end



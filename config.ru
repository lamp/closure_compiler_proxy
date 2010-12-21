require "rubygems"
require "bundler"
Bundler.require(:default)

Sinatra::Application.set(
  :run => false,
  :environment => ENV['RACK_ENV']
)

if ENV["RACK_ENV"] == "production"
  FileUtils.mkdir_p 'log' unless File.exists?('log')
  log = File.new("log/sinatra.log", "a")
  $stdout.reopen(log)
  $stderr.reopen(log)
  root_dir = File.dirname(__FILE__)
  set :root, root_dir
  set :environment, ENV["RACK_ENV"]

  disable :run
end

require 'app'

run App
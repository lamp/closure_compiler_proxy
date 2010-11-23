require "rubygems"
require "bundler"
Bundler.require(:default)

Sinatra::Application.set(
  :run => false,
  :environment => ENV['RACK_ENV']
)

FileUtils.mkdir_p 'log' unless File.exists?('log')
log = File.new("log/sinatra.log", "a")
$stdout.reopen(log)
$stderr.reopen(log)

root_dir = File.dirname(__FILE__)

set :root, root_dir
set :environment, ENV["RACK_ENV"]
disable :run

require 'app'

run App
require "rubygems"
require "bundler"
Bundler.require(:default)

Sinatra::Application.set(
  :run => false,
  :environment => ENV['RACK_ENV']
)

require 'app'
run App
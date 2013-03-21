# coding: utf-8

require "rubygems"
require "bundler"
Bundler.setup

require 'em-ftpd'
require 'ostruct'

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

RSpec.configure do |config|
  config.filter_run :focus => true
  config.run_all_when_everything_filtered = true
  # config.include ReaderSpecHelper
end

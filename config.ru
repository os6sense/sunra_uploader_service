# File: uploader_service/config.ru
require 'rubygems'
require 'sinatra'
require 'sunra_config/global'
require 'rack/cors'

require File.expand_path('../../../lib/format_proxy', __FILE__)
require File.expand_path('../uploader_service', __FILE__)

set :environment, ENV['RACK_ENV'].to_sym

configure :production, :staging do
  disable :run, :reload
end

use Rack::Cors do |config|
  config.allow do |allow|
    allow.origins '*'
    allow.resource '*',
                   :methods => [:get, :post, :put, :delete],
                   :headers => :any,
                   :max_age => 0
  end
end

format_proxy = Sunra::Utils::FormatProxy.new(
  Sunra::Config::Global.api_key,
  Sunra::Config::Global.project_rest_api_url
)

puts 'Starting Uploader Service'

run Sunra::Service::Uploader.new(Sunra::Config::Global, format_proxy)

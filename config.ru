# File: uploader_service/config.ru
require 'rubygems'
require 'sinatra'
require 'rack/cors'

require 'sunra_utils/config/global'
require 'sunra_utils/format_proxy'

require_relative 'uploader_service'

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
  Sunra::Utils::Config::Global.api_key,
  Sunra::Utils::Config::Global.project_rest_api_url
)

puts 'Starting Uploader Service'

run Sunra::Service::Uploader.new(Sunra::Utils::Config::Global, format_proxy)

# File:: uploader_service.rb

require 'sinatra'
require 'eventmachine'
require 'json'

require 'sunra_utils/logging/passenger/sinatra'

require_relative 'uploader_api'

module Sunra
  module Service
    class Uploader < Sinatra::Base
      helpers Sunra::Utils::Logging::Passenger::Sinatra

      configure :production, :staging, :development do
        set :logger, Sunra::Utils::Logging::Passenger::Sinatra::Logger.new(root, environment)
      end

      # ==== Description
      # A service which handles uploading of files to the webserver
      def initialize(global_config, format_proxy)
        super()
        @global_config = global_config
        @api = Sunra::Uploader::API.new(format_proxy)
      end

      get '/' do
        halt 'Uploader Service'
      end

      get '/status' do
        logger.error "hello"
        halt @api.status.to_json
      end

      # The upload should not be started manually, rather it should occur at
      # a predetermined time, however manual_start allows for force uploading
      get '/manual_start' do
        @api.start.to_json
      end

      get '/stop' do
        @api.stop
        halt @api.status.to_json
      end
    end
  end
end

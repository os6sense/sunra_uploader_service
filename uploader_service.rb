# File:: uploader_service.rb

require 'sinatra'
require 'eventmachine'
require 'json'

require 'sunra_utils/logging/passenger/sinatra'
require 'sunra_utils/config/uploader'

require_relative 'uploader_api'

module Sunra
  module Service
    class Uploader < Sinatra::Base
      helpers Sunra::Utils::Logging::Passenger::Sinatra

      configure :production, :staging, :development do
        set :logger,
             Sunra::Utils::Logging::Passenger::Sinatra::Logger.new(root, environment)
      end

      # ==== Description
      # A service which handles uploading of files to the webserver
      def initialize(format_proxy)
        super()
        @api = Sunra::Uploader::API.new(format_proxy,
                                        Sunra::Utils::Config::Uploader,
                                        logger)
      end

      get '/' do
        halt 'Uploader Service'
      end

      # TODO, respect the api key =. I use this also in the recording service
      # hence it needs abstracting out.
      get '/status.?:format?' do
        if params[:format] && params[:format] == 'html'
          erb :status, locals: {api_status: @api.status}
        else
          halt @api.status.to_json
        end
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

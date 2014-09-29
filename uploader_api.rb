# File:: uploader.api

require 'eventmachine'

require 'sunra_config/uploader'

require_relative 'upload_history'
require_relative 'archive_proxy'
require_relative 'recording_format'

module Sunra
  module Uploader
    # Description::
    class API
      attr_reader :timer

      def initialize(format_proxy)
        @format_proxy  = format_proxy
        @history       = Sunra::Utils::History.new(format_proxy)
        @uploader      = Sunra::Utils::Uploader.new(Sunra::Config::Uploader)

        @archive_proxy = Sunra::Utils::ArchiveProxy.new(
          Sunra::Config::Uploader.archive_api_key,
          Sunra::Config::Uploader.archive_server_rest_url)
      end

      # ==== Description
      # Return the status of any current uploads, along with recent history,
      # any pending uploads and detail the automated upload time.
      def status
        {
          history: @history.recent(5),
          uploading: @uploader.status,
          pending: pending.map { | rf | rf.source },
          upload_at: 'See Cron' # @timer.time
        }
      end

      def process_pending
        pending.each do | rf |
          if @uploader.upload(rf.source, rf.destination)
            @archive_proxy.notify(rf, @uploader.destination)
            @format_proxy.update_format_field(rf.id, :upload, false)
            @history.add(rf, @uploader)
            @uploader.reset_status
          end
        end
      end

      def process_pending_complete(result)
        # log whenever it has run
      end

      # ==== Description
      # Return the status of any current uploads, along with recent history,
      # Performs a check for any files waiting for upload and if any are
      # found, individually uploads them
      def start
        return status if @uploader.uploading

        EM::defer(-> { process_pending },
                  proc { | result | process_pending_complete(result) })
        status
      end

      def stop
        @uploader.abort!
      end

      private

      # ==== Description
      # obtains the list of pending files to be uploaded via the rest api
      def pending
        #puts @format_proxy.formats_for('upload')
        @format_proxy.formats_for('upload').map do | rf |
          Sunra::Utils::RecordingFormat.new(rf)
        end
      end
    end
  end
end

# File:: uploader_api.api

require 'eventmachine'

require_relative 'upload_history'
require_relative 'archive_proxy'
require_relative 'recording_format'

module Sunra
  module Uploader
    # Description::
    class API
      include Sunra::Utils

      def initialize(format_proxy, config, logger = nil)
        @format_proxy     = format_proxy
        @history          = Sunra::Uploader::History.new(format_proxy)
        @uploader         = Sunra::Utils::Uploader.new(config, logger)
        @archive_proxy    = ArchiveProxy.new(config.archive_api_key,
                                             config.archive_server_rest_url)
      end

      # ==== Description
      # Return the status of any current uploads, along with recent history,
      # any pending uploads and detail the automated upload time.
      def status
        { history:    @history.recent(5),
          uploading:  @uploader.status,
          host:       @uploader.host,
          pending:    pending_status_to_hash,
          upload_at: 'See Cron' }
      end

      def process_pending
        pending.each do |rf|
          upload_start_time = Time.now

          if @uploader.upload(rf.source, rf.destination)
            @archive_proxy.notify(rf, @uploader.destination)
            @format_proxy.update_format_field(rf.id, :upload, false)
            @history.add(rf, upload_start_time, @uploader)
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
                  proc { |result| process_pending_complete(result) })
        status
      end

      def stop
        @uploader.abort!
      end

      private

      # ==== Description
      # obtains the list of pending files to be uploaded via the rest api
      def pending
        @format_proxy.formats_for('upload').map do |rf|
          Sunra::Utils::RecordingFormat.new(rf)
        end
      end

      def pending_status_to_hash
        pending.map do |rf|
          { project_id:     rf.project_id,
            project_name:   rf.project_name,
            client_name:    rf.client_name,
            start_time:     rf.to_recording(rf.booking_id)[:recording][:start_time],
            end_time:       rf.to_recording(rf.booking_id)[:recording][:end_time],
            base_filename:  rf.base_filename,
            format:         rf.format }
        end
      end
    end
  end
end

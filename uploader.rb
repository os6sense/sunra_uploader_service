require 'forwardable'

require_relative '../../lib/sftp_uploader'
#require 'sunra_logging'

module Sunra
  module Utils
    # ==== Description
    # Wrapper around @SFTPUploader which handles
    class Uploader
      include SunraLogging

      extend Forwardable

      def_delegators :@sftp, :reset_status, :status

      attr_reader :source,
                  :destination,
                  :progress,
                  :uploading

      # ==== Description
      # Init.
      #
      # ==== Params
      # A config class which contains the methods
      # +upload_server_address+:: The address of the server to upload to
      # +sftp_username+:: The username to login to the server with
      # +upload_base_directory+:: The base directory to which all paths will
      #                           be appended to.
      # +sftp_password+:: optional?
      def initialize(config)
        @sftp = SFTPUploader.new(config.archive_server_address,
                                 config.sftp_username,
                                 config.archive_base_directory,
                                 config.sftp_password)
      end

      def abort!
        @uploading = false
        @sftp.abort!
        @sftp.reset_status
      end

      # ==== Description
      # start uploading from source to destination. TODO call &block on
      # completion.
      #
      # ==== Params
      # +source+:: The full path and filename of the local file to upload.
      # +destination+:: The path and filename to upload to. Not that if
      #                 +upload_base_directory+ was specified in the config
      #                 that this will be prepended to the destination path.
      def upload(source, destination)
        fail "Cannot upload while upload is in progress"\
          if @uploading

        @uploading = true

        begin
          @sftp.upload(source, destination)
        rescue Exception => msg
          logger.debug msg
          return false
        ensure
          @uploading = false
        end

        return true
      end
    end
  end
end

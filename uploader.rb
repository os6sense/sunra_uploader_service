require 'forwardable'

require 'sunra_utils/sftp_uploader'

module Sunra
  module Utils
    # ==== Description
    # Wrapper around @SFTPUploader which handles
    class Uploader
      attr_accessor :logger

      extend Forwardable

      def_delegators :@sftp, :reset_status, :status, :host

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
      def initialize(config, logger = nil)
        @sftp = Sunra::Utils::SFTP::Uploader.new(config.archive_server_address,
                                 config.sftp_username,
                                 config.archive_base_directory,
                                 config.sftp_password)
        @sftp.logger = logger
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
        msg = "Cannot upload a file while an upload is already in progress"
        fail msg if @uploading

        @uploading = true

        begin
          @sftp.upload(source, destination)
        rescue Exception => e_msg
          @sftp.logger.error(e_msg)
          return false
        ensure
          @uploading = false
        end

        return true
      end
    end
  end
end

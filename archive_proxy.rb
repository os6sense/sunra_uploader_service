# File:: archive_proxy.rb
#
# When uploading a file to the archive site it is neccessary to make an entry
# on the archive server with details as to the project and booking to which
# the file belongs. This is seperate to the local server/rest api used to
# store details about bookings/recordings which have been performed locally.
#
# While the archive server has many details in common with the local server,
# not every recording will be uploaded, not every file format will be uploaded,
# and there is the additional matter of adding meta information and securing
# the recordings. Hence a seperate API is used for this. Perhaps they both
# should have a common base?
#
require 'json'

require 'sunra_utils/logging'
require 'sunra_utils/rest_client'
require 'sunra_utils/logging/passenger/sinatra'

require_relative 'proxy/all'

module Sunra
  module Utils
    # ==== Description
    # Provide a proxy for the parts of the rest service which deal with the
    # saving of information about recording formats.
    class ArchiveProxy
      include Sunra::Utils::Logging

      class ArchiveProxyError < StandardError; end

      # Description
      # Provide access to the recordings via the rails servers JSON/REST API
      # Params
      # +api_key+ The api_key to access the archive rest api
      # +resource_url+:: The base URL for the project_manager service
      #                  e.g. 'http://localhost/archive
      def initialize(api_key, resource_url)
        @rest_client = RestClient.new(resource_url, api_key)
      end

      # ==== Description
      # Notify the archive site that a new recording is avilable. This is
      # done through the archive sites rest API. Notify does everything
      # neccessay to create the neccessary records on the archive server
      # based on the recording format record returned from the local
      # recording db api AND the destination url of the file on the server.
      #
      # ==== Params
      # +rf+:: recording_format record. See recording_format.rb/RecFormat
      #        for a full description.
      def notify(rf, destination)
        logger.info('ArchiveProxy') { 'Notifying Archive Service' }
        logger.info('ArchiveProxy') { "destination: #{destination}" }

        p_id = ProjectProxy.new(@rest_client).create(rf).id
        logger.debug('ArchiveProxy') { "Project Created #{p_id}" }
        s_id = SessionProxy.new(@rest_client).create(p_id, rf).id
        logger.debug('ArchiveProxy') { "Session Created #{s_id}" }
        r_id = RecordingProxy.new(@rest_client).create(p_id, s_id, rf).id
        logger.debug('ArchiveProxy') { "Recording Created #{r_id}" }
        MediumProxy.new(@rest_client).create(p_id, s_id, r_id, rf)
        logger.debug('ArchiveProxy') { "Recording Created #{r_id}" }

        return true
      rescue => error
        logger.error('ArchiveProxy') { 'Error During Archive Service Notification' }
        logger.error('ArchiveProxy') { error.message }
        return false
      end
    end
  end
end

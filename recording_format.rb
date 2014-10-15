require 'json'

require 'sunra_utils/config/global'
require 'sunra_utils/recording_db_proxy'
require 'sunra_utils/format_proxy'

require_relative 'uploader'

module Sunra
  module Utils
    # ==== Description
    # From the rest_api to the local project manager we obtain a list of
    # recoding_format records which have been flagged for upload to the
    # archive server. The JSON record record returned is a combination of the
    # format and the recording, for example, as follows:
    #
    # {"booking_id":26,
    # "copy":false,
    # "created_at":"2014-06-09T22:08:33+01:00",
    # "directory":"/mnt/RAID/VIDEO/NEWSessions/de23de3<snip>78fb34b9089b/26/",
    # "encrypt":false,
    # "encrypted":false,
    # "end_time":"2014-06-09T22:09:00+01:00",
    # "filesize":279032,
    # "fixed_moov_atom":false,
    # "format":"1",
    # "id":77,
    # "project_id":"de23de37b4515ed09<snip>faa7be2e578fb34b9089b",
    # "recording_id":20,
    # "remote_directory":null,
    # "sha1hash":"",
    # "start_time":"2014-06-09T22:08:00+01:00",
    # "updated_at":"2014-06-09T22:09:51+01:00","upload":true,
    # "recording":{
    #   "base_filename":"2014-06-09-220832",
    #   "booking_id":26,
    #   "created_at":"2014-06-09T22:08:33+01:00",
    #   "end_time":"2014-06-09T22:08:58+01:00",
    #   "group_number":1,
    #   "id":20,
    #   "start_time":"2014-06-09T22:08:32+01:00",
    #   "updated_at":"2014-06-09T22:09:36+01:00"
    # }}
    #
    # We want to use this to upload to the archive server **AND** add an
    # entry to the archive servers list of files via its rest API. Many of
    # the fields in the recording_format record returned from the project
    # manager will be a one to one match but the recording_format does
    # not return booking or project details hence additional calls are needed.
    class RecordingFormat
      def initialize(rf)
        @rf = rf
      end

      # ==== Description
      def project_id
        @rf['project_id']
      end

      # ==== Description
      def booking_id
        @rf['booking_id']
      end

      # ==== Description
      # return the filename
      def base_filename
        @rf['recording']['base_filename']
      end

      # ==== Description
      # Although the file format *should* be the litteral string value it
      # is possible that it might be an integer which needs looking up.
      # return the file format as a string whether it is an int or string
      def format
        lookup_val = Integer(@rf['format'])
        @_format ||= format_proxy.lookup_format_name(lookup_val)
      rescue
        @rf['format']
      end

      # ==== Description
      # ID of the recording format itself
      def id
        @rf['id']
      end

      # ==== Description
      # Full pathname and filename to the file to upload
      def source
        @_source ||= "#{@rf['directory']}/#{base_filename}.#{format}"
      end

      # ==== Description
      # Just the pathname of where to upload to
      def destination_path
        @_destination_path ||= "#{@rf['project_id']}/#{@rf['booking_id']}/"
      end

      # ==== Description
      # Full pathname and filename of where to upload to
      def destination
        @_destination ||= "#{@rf['project_id']}/#{@rf['booking_id']}/"\
          "#{base_filename}.#{format}"
      end

      # ==== Description
      # Return a hash which can be passed to the sunra_rest_client in order
      # to create a project record on the archive server.
      #
      # Note that the information in the recording_format record is missing
      # the project and client names hence there are obtained via a lookup
      # of the project via the project managers rest api.
      #
      # Yes, I should have just bloody included them in the record.
      def to_project
        project = JSON.parse(
          db_api.get_project(project_id,
                             Sunra::Config::Global.studio_id)
        )

        { project: { uuid: project_id,
                     name: project['project_name'],
                     client: project['client_name']
        } }
      end

      # ==== Description
      # Return a hash which can be passed to the sunra_rest_client in order
      # to create a session record on the archive server.
      #
      # Note that the information in the recording_format record is missing
      # the dates, times and seesion id  hence there are obtained via a lookup
      # of the booking via the project managers rest api.
      #
      # Yes, I should have just bloody included them in the record too.
      def to_session(project_id)
        booking = db_api.get_booking(project_id,
                                     booking_id,
                                     Sunra::Config::Global.studio_id)
        booking = JSON.parse(booking)

        { session: {
          project_id: project_id,
          studio: Sunra::Config::Global.studio_id,
          date: booking['date'],
          start_time: booking['start_time'],
          end_time: booking['end_time']
        } }
      end

      # ==== Description
      # Return a hash which can be passed to the sunra_rest_client in order
      # to create a recording record on the archive server.
      #
      # ==== Params
      # session_id - this is the id of the session on the archive server
      # to which to add the recording.
      def to_recording(session_id)
        { recording: {
          session_id: session_id,
          duration: '',
          start_time: @rf['recording']['start_time'],
          end_time: @rf['recording']['end_time'],
          basename: base_filename,
          location: destination_path,
          location_key: ''
        } }
      end

      # ==== Description
      # Return a hash which can be passed to the sunra_rest_client in order
      # to create a medium record on the archive server.
      #
      # ==== Params
      # id - this is the id of the recording record on the archive server
      # to which to add the medium
      def to_medium(id)
        { medium: {
          recording_id: id,
          media_type: format,
          size: @rf['filesize'],
          encrypted: @rf['encrypted']
        } }
      end

      private

      def db_api
        @_db_api ||= Sunra::Recording::DB_PROXY.new(
                        Sunra::Config::Global.api_key,
                        Sunra::Config::Global.project_rest_api_url)
      end

      def format_proxy
        @_format_proxy ||= Sunra::Utils::FormatProxy.new(
          Sunra::Config::Global.api_key,
          Sunra::Config::Global.project_rest_api_url
        )
      end
    end
  end
end

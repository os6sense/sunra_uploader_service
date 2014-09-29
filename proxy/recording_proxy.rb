require_relative 'archive_base_proxy'

module Sunra
  module Utils
    # ==== Description
    # A proxy to create a project entry on the archive server
    class RecordingProxy < ArchiveClassProxyBase
      # ==== Description
      # Add a recording entry to the archive.
      #
      # ==== Params
      # +p_id+:: project_id, same id as on the client and archive
      # +s_id+:: session_id, this is the archive session id
      # +fr+:: RecordingFormat
      def create(p_id, s_id, rf)
        recording = rf.to_recording(s_id)

        url = "/ID/#{p_id}/sessions/#{s_id}/recordings.json"

        super(url, recording)
        return self
      end
    end
  end
end

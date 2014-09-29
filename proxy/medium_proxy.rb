require_relative 'archive_base_proxy'

module Sunra
  module Utils
    # ==== Description
    # A proxy to create a media/medium entry on the archive server.
    class MediumProxy < ArchiveClassProxyBase
      # ==== Description
      # Add a media (medium) entry to the archive
      #
      # ==== Params
      # +p_id+:: project_id, same id as on the client and archive
      # +s_id+:: session_id, this is the archive session id
      # +r_id+:: recording_id, this is the archive recording id
      #
      # ==== Notes
      # recording_id: id,
      # media_type: media_type,
      # size: size,
      # encrypted: encrypted
      def create(p_id, s_id, r_id, rf)
        medium = rf.to_medium(r_id)
        url = "/ID/#{p_id}/sessions/#{s_id}/recordings/#{r_id}/media.json"

        super(url, medium)
        return self
      end
    end
  end
end

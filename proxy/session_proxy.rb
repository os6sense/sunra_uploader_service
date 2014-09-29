require_relative 'archive_base_proxy'

module Sunra
  module Utils
    # ==== Description
    # A proxy to create a session entry on the archive server
    class SessionProxy < ArchiveClassProxyBase
      # ==== Description
      # Add a recording entry to the archive.
      #
      # ==== Params
      # +p_id+:: project_id, same id as on the client and archive
      #
      # ==== Notes
      # project_id: values[:project_id],
      # date: values[:date],
      # start_time: values[:start_time],
      # end_time: values[:end_time],
      # studio: values[:studio]
      def create(p_id, rf)
        session = rf.to_session(p_id)
        url = "/ID/#{p_id}/sessions.json"

        super(url, session)
        return self
      end
    end
  end
end

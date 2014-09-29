require_relative 'archive_base_proxy'

module Sunra
  module Utils
    # ==== Description
    # A proxy to create a project on the archive server
    class ProjectProxy < ArchiveClassProxyBase
      # Note, overrides the create method and DOES NOT call super
      def create(rf)
        if (existing =
              _record_exists?("/ID/#{rf.project_id}.json")).nil?
          prj = rf.to_project()
          @json = JSON.parse(@rest_client.create('/ID.json', prj))
        else
          @json = JSON.parse(existing)
        end
        return self
      end

      # The project uses a uuid rather than id
      def id
        @json['uuid']
      end

      private

      # Perform a get against the archive rest API. If the API returns a 404
      # the either the get URL is malformed or the record doesnt exist.
      def _record_exists?(get_url)
        existing = @rest_client.get(get_url)

        return nil if (existing.is_a? Integer) \
            && (existing == Sunra::Utils::RestClient::NOT_FOUND)

        existing
      end
    end
  end
end

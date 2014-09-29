#require_relative 'archive_base_proxy'

module Sunra
  module Utils
    # ==== Description
    # Base class for the various proxy implementations
    class ArchiveClassProxyBase
      def initialize(rest_client)
        @rest_client = rest_client
        @json = nil
      end

      def id
        @json['id']
      end

      protected

      # If the response contains a 'base' field, attempt to parse the
      # contents for an id which identifies the id key of the record
      # to which the post would have been a duplicate of.
      def error_to_id_hash
        {
          'id' => JSON.parse(@rest_client.error_response)['base'][0]
            .split(':')[1].strip
        }
      end

      # We have no way to know if a some records exist until we post
      # them. If it does exist we should get a 422 message IF the record
      # fails due to a unique validation on the model, and a 500 message
      # if it fails due to a constrant on the DB (index).
      #
      # Sadly rails default 422 message is *useless* in that it doesn't
      # provide the id of the record which it failed against hence it is
      # neccessay to provide a custom validates_with class for the model
      # and return the id as part or the error response.
      #
      # Rails sux.
      def create(url, record)
        if (result = @rest_client.create(url, record)) == \
          Sunra::Utils::RestClient::UNPROCESSABLE_ENTITY
          @json = error_to_id_hash
        else
          @json = JSON.parse(result)
        end
      # rescue
        # raise ArchiveProxyError,
          # "Failed To Create Record On Archive."
      end
    end
  end
end


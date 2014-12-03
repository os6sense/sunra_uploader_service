require_relative 'upload_history_db'
require_relative 'upload_history_entry'

module Sunra
  module Uploader
    # ==== Description
    # Simple abstraction to provide a list of files that have been uploaded
    class History
      def initialize(db_api)
        @history = []

        @_hdb = HistoryDB.new()
        @_hdb.load(@history)
      end

      # ==== Description
      # add a file to the history list
      #
      # ==== Parameters
      # +rf+ :: RecordingFormat record
      # +start_time+ :: The time at which the upload was started
      # +uploader+ :: The uploader which should return a status hash
      def add(rf, start_time, uploader)
        hash = HistoryEntry.new.from_recording_format(rf)
        hash.add_time(start_time)
        hash.add_status(uploader.status)

        @history << hash
        hash[:id] = @_hdb.add(hash)
      end

      # ==== Description
      # Return the result of the last n upload attempts.
      def recent(n = 5)
        return @history[-n..-1] if n < @history.size
        return @history[0..n]
      end
    end
  end
end

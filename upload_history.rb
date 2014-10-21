require_relative 'upload_history_db'
require_relative 'upload_history_entry'

module Sunra
  module Uploader
    # Fifo queue so that we dont have to hit the DB every time?
    class History
      def initialize(db_api)
        @_hdb = HistoryDB.new()
        @history = []
        @_hdb.load(@history)
      end

       # Record an upload and its status (success/fail) + errors
      def add(rf, start_time, uploader)
        hash = HistoryEntry.new.from_recording_format(rf)
        hash.add_time(start_time)
        hash.add_status(uploader.status)

        @history << hash
        hash[:id] = @_hdb.add(hash)
      end

      # Return the result of the last n upload attempts.
      def recent(n = 5)
        return @history[-n..-1] if n < @history.size
        return @history[0..n]
      end
    end


  end
end

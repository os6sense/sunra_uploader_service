
module Sunra
  module Utils
      # Fifo queue so that we dont have to hit the DB every time?
    class History
      def initialize(db_api)
        @history = []
      end

        # Record an upload and its status (success/fail) + errors
      def add(rf, uploader)
        @history << { source: rf.source,
                      destination: rf.destination,
                      status: uploader.status }

      end

        # Return the result of the last n upload attempts.
      def recent(n = 5)
        return @history[-n..-1] if n < @history.size
        return @history[0..n]
      end
    end
  end
end

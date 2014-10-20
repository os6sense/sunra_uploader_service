
module Sunra
  module Utils
      # Fifo queue so that we dont have to hit the DB every time?
    class History
      def initialize(db_api)
        @history = []
        self.load
      end

        # Record an upload and its status (success/fail) + errors
      def add(rf, start_time, uploader)
        @history << { project_name: rf.project_name,
                      client_name: rf.client_name,
                      base_filename: rf.base_filename,
                      source: rf.source,
                      format: rf.format,
                      destination: rf.destination,
                      timestamp: Time.now,
                      duration: Time.now - start_time,
                      status: uploader.status }
      end

        # Return the result of the last n upload attempts.
      def recent(n = 5)
        return @history[-n..-1] if n < @history.size
        return @history[0..n]
      end

      def save
      end

      def load
      end
    end
  end
end

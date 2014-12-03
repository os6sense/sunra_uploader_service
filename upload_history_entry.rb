
module Sunra
  module Uploader
    # === Description
    # Groups methods which provide the hash representation of the history
    class HistoryEntry < Hash
      # ==== Description
      # Return a hash from a db row
      def from_db_row(row)
        self[:id] = row[0]
        self[:project_name] = row[1]
        self[:client_name] = row[2]
        self[:base_filename] = row[3]
        self[:source] = row[4]
        self[:format] = row[5]
        self[:destination] = row[6]
        self[:timestamp] = row[7]
        self[:duration] = row[8]
        self[:status] = row[9]
        self[:filesize] = row[10]
        self[:bytes_written] = row[11]

        self
      end

      # === Description
      # Return a hash from a RecordingFormat Record
      def from_recording_format(rf)
        self[:project_name] = rf.project_name
        self[:client_name] = rf.client_name
        self[:base_filename] = rf.base_filename
        self[:source] = rf.source
        self[:format] = rf.format
        self[:destination] = rf.destination
        self[:filesize] = rf.filesize

        self
      end

      # === Description
      # add the start_time of the upload and calculate the duration, adding
      # these fields to the hash
      def add_time(start_time)
        self[:timestamp] = Time.now
        self[:duration] = Time.now - start_time
        self
      end

      # === Description
      # Add status completiong information and bytes_written info to the hash
      def add_status(status)
        self[:status] = status[:complete]
        self[:bytes_written] = status[:bytes_written]
      end
    end
  end
end

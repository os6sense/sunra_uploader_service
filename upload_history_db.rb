require 'sqlite3'
require_relative 'upload_history_entry'

# A simple persistance mechanism for the upload history
module Sunra
  module Uploader
    class HistoryDB
      def initialize
        open
        create
      end

      def open
        @db = SQLite3::Database.open 'db/upload_history.db'
      end

      def handle_error(e)
        puts "ERROR HistoryDB:: #{e.message}"
      end

      def create
        @db.execute %q(CREATE TABLE IF NOT EXISTS UPLOAD_HISTORY(
                       id INTEGER PRIMARY KEY,
                       project_name TEXT,
                       client_name TEXT,
                       base_filename TEXT,
                       source TEXT,
                       format TEXT,
                       destination TEXT,
                       timestamp TEXT,
                       duration FLOAT,
                       status TEXT,
                       filesize INT,
                       bytes_written INT))
      rescue Exception => e
        handle_error(e)
      end

      def close
        @db.close if @db
      end

      def load(array)
        stm = @db.prepare 'SELECT * FROM UPLOAD_HISTORY'
        stm.execute.each do |row|
          array << HistoryEntry.new.from_db_row(row)
        end
      rescue Exception => e
        handle_error(e)
      ensure
        stm.close if stm
      end

      def add(hash)
        sql = %Q(INSERT INTO UPLOAD_HISTORY
                 (project_name, client_name, base_filename, source, format,
                 destination, timestamp, duration, status, filesize,
                 bytes_written)
                 VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?))

        stm = @db.prepare(sql)
        stm.execute(hash[:project_name],
                    hash[:client_name],
                    hash[:base_filename],
                    hash[:source],
                    hash[:format],
                    hash[:destination],
                    hash[:timestamp].to_s,
                    hash[:duration].to_s,
                    hash[:status].to_s,
                    hash[:filesize],
                    hash[:bytes_written])
          return @db.last_insert_row_id
      rescue Exception => e
        handle_error(e)
      ensure
        stm.close if stm
      end
    end
  end
end

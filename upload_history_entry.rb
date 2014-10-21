
class HistoryEntry < Hash
  def initialize
  end

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

  def add_time(start_time)
    self[:timestamp] = Time.now
    self[:duration] = Time.now - start_time
    self
  end

  def add_status(status)
    self[:status] = status[:complete]
    self[:bytes_written] = status[:bytes_written]
  end

end

require 'spec_helper'

require 'sunra_utils/config/uploader'
require_relative '../uploader_api.rb'

describe Sunra::Uploader::API do
  describe :initialize do
  end

  describe :status do
  end

  describe :start do
  end

  describe :pause do
  end

  describe :pending do
  end

  describe :upload_pending do
  end

# inform the web-based content management system that
# 1) A new file has been uploaded
# 2) It belongs to project/booking
# 3) Meta data about the file
#
# project_id
# booking_id
# recording_id
# format_id
# studio_id
# basefilename
# format
# date
# start_time
# stop_time
# size
# email_address of the target recipient?
#
# perhaps a CRC hash to check it isnt corrupted in the future?

# QUESTIONS: WHERE DOES THE DATA LIVE ON THE WEBSERVER?
#            WHO SENDS THE EMAIL TO THE USER

# REQUIREMENTS
# Files are made available for secure download over https by clients
end

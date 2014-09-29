require 'sunra_config/uploader'
require 'bogus/rspec'

describe Sunra::Config::Uploader do
  describe :Config do

    before :each do
      @config = Sunra::Config::Uploader
      @config.bootstrap_on_require(
                         File.expand_path('./test_config_values.yml', __dir__))
    end

    describe :archive_server_address do
      it 'provides the address of the server' do
        @config.archive_server_address.should eq 'address'
      end
    end

    describe :archive_server_port do
      it 'provides the port for the upload server' do
        @config.archive_server_port.class.should eq Fixnum
        @config.archive_server_port.should eq 22
      end
    end

    describe :archive_base_directory do
      it 'returns a path as a string' do
        @config.archive_base_directory.should eq '/a/sub/directory'
      end
    end

    describe :sftp_ssl_key do
      it 'method exists' do
        @config.sftp_ssl_key.should eq '/path/to/key/file'
      end
    end

    describe :sftp_username do
      it 'returns the username' do
        @config.sftp_username.should eq 'username'
      end
    end

    describe :sftp_password do
      it 'returns the password' do
        @config.sftp_password.should eq 'password'
      end
    end

    describe :start_time do
      it 'returns the start time as a string' do
        @config.start_time.should eq '01:00'
      end
    end

  end
end

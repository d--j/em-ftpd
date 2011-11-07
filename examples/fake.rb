# coding: utf-8

# a super simple FTP server with hard coded auth details and only two files
# available for download.
#
# Usage:
#
#   ruby -Ilib examples/fake.rb

require 'rubygems'
require 'bundler'

Bundler.setup

require 'em-ftpd'

class FakeFTPDriver
  FILE_ONE = "This is the first file available for download.\n\nBy James"
  FILE_TWO = "This is the file number two.\n\n2009-03-21"

  def change_dir(user, path, &block)
    yield path == "/" || path == "/files"
  end

  def dir_contents(user, path, &block)
    case path
    when "/"      then
      yield [ dir_item("files"), file_item("one.txt", FILE_ONE.bytesize) ]
    when "/files" then
      yield [ file_item("two.txt", FILE_TWO.bytesize) ]
    else
      yield []
    end
  end

  def authenticate(user, pass, &block)
    yield user == "test" && pass == "1234"
  end

  def bytes(user, path, &block)
    yield case path
          when "/one.txt"       then FILE_ONE.size
          when "/files/two.txt" then FILE_TWO.size
          else
            false
          end
  end

  def get_file(user, path, &block)
    yield case path
          when "/one.txt"       then FILE_ONE
          when "/files/two.txt" then FILE_TWO
          else
            false
          end
  end

  def put_file(user, path, data, &block)
    yield false
  end

  def delete_file(user, path, &block)
    yield false
  end

  def delete_dir(user, path, &block)
    yield false
  end

  def rename(user, from, to, &block)
    yield false
  end

  def make_dir(iser, path, &block)
    yield false
  end

  private

  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => true, :size => 0)
  end

  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name, :directory => false, :size => bytes)
  end

end

# signal handling, ensure we exit gracefully
trap "SIGCLD", "IGNORE"
trap "INT" do
  puts "exiting..."
  puts
  EventMachine::run
  exit
end

EM.run do
  puts "Starting ftp server on 0.0.0.0:5555"
  EventMachine::start_server("0.0.0.0", 5555, EM::FTPD::Server, FakeFTPDriver.new)
end

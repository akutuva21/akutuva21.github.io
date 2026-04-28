require 'minitest/autorun'
require 'minitest/mock'
require 'digest/md5'

# Load the mock Liquid module
require_relative '../mock_gems/liquid'

# Require the plugin
require_relative '../_plugins/cache-bust'

class TestCacheBust < Minitest::Test
  include Jekyll::CacheBust

  def test_bust_file_cache
    file_name = 'assets/css/main.css'
    file_content = 'body { color: red; }'
    expected_digest = Digest::MD5.hexdigest(file_content)

    File.stub :read, file_content do
      result = bust_file_cache(file_name)
      assert_equal "#{file_name}?#{expected_digest}", result
    end
  end

  def test_bust_css_cache
    file_name = 'assets/css/style.css'

    # Simulate finding two files in the directory
    files_in_dir = ['assets/_sass/a.scss', 'assets/_sass/b.scss']

    # Mock Dir.[] to return the fake files
    Dir.stub :[], files_in_dir do

      # We need to mock File.directory? and File.read
      original_directory = File.method(:directory?)
      original_read = File.method(:read)

      # Mock File.directory? to return false for our fake files
      directory_stub = proc do |f|
        files_in_dir.include?(f) ? false : original_directory.call(f)
      end

      # Mock File.read to return different content for our fake files
      read_stub = proc do |f|
        if f == 'assets/_sass/a.scss'
          'content a'
        elsif f == 'assets/_sass/b.scss'
          'content b'
        else
          original_read.call(f)
        end
      end

      File.stub :directory?, directory_stub do
        File.stub :read, read_stub do
          result = bust_css_cache(file_name)
          expected_content = 'content acontent b'
          expected_digest = Digest::MD5.hexdigest(expected_content)
          assert_equal "#{file_name}?#{expected_digest}", result
        end
      end
    end
  end
end

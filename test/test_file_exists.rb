require "minitest/autorun"
require "liquid"
require "minitest/mock"

# Mock missing dependencies
module Jekyll
  class Plugin; end
  class Generator < Plugin; end
  class Site; end
end

require_relative "../_plugins/file-exists.rb"

class TestFileExistsTag < Minitest::Test
  def setup
    @context = Liquid::Context.new

    # We mock out config to return our test config
    @site_mock = Object.new
    def @site_mock.config
      { "source" => "/var/www/site" }
    end

    @context.registers[:site] = @site_mock
  end

  def test_render_true_when_file_exists
    tag = Jekyll::FileExistsTag.parse("file_exists", "existing_file.txt", Liquid::Tokenizer.new(""), Liquid::ParseContext.new)

    File.stub(:exist?, true) do
      result = tag.render(@context)
      assert_equal "true", result
    end
  end

  def test_render_false_when_file_does_not_exist
    tag = Jekyll::FileExistsTag.parse("file_exists", "missing_file.txt", Liquid::Tokenizer.new(""), Liquid::ParseContext.new)

    File.stub(:exist?, false) do
      result = tag.render(@context)
      assert_equal "false", result
    end
  end

  def test_render_strips_whitespace
    tag = Jekyll::FileExistsTag.parse("file_exists", " file_with_whitespace.txt ", Liquid::Tokenizer.new(""), Liquid::ParseContext.new)

    # Check that it strips whitespace
    # we need to be careful with minitest stubs

    # Record the path passed to File.exist?
    passed_path = nil

    stub_proc = proc do |path|
      passed_path = path
      true
    end

    File.stub(:exist?, stub_proc) do
      tag.render(@context)
    end

    assert_equal "/var/www/site/ file_with_whitespace.txt", passed_path
  end
end

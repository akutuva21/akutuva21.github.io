require 'minitest/autorun'
require 'liquid'
require 'nokogiri'

# Mock ActiveSupport to avoid full dependency loading if possible, or just require it
require 'active_support/all'

# Require the plugin
require_relative '../_plugins/google-scholar-citations'

class GoogleScholarCitationsTagTest < Minitest::Test
  def setup
    # Clear cache before each test
    Jekyll::GoogleScholarCitationsTag::Citations.clear
  end

  def test_error_handling_returns_na
    # Mock context
    context = {
      "scholar_id" => "123",
      "article_id" => "456"
    }

    # Setup the tag
    tag = Jekyll::GoogleScholarCitationsTag.parse("google_scholar_citations", "scholar_id article_id", Liquid::Tokenizer.new(""), Liquid::ParseContext.new)

    # Stub URI.open to raise an exception
    URI.stub(:open, ->(*args) { raise StandardError.new("Simulated network error") }) do
      # Redirect stdout to avoid expected error message during test
      stdout_backup = $stdout
      $stdout = StringIO.new

      begin
        result = tag.render(context)
        assert_equal "N/A", result
      ensure
        $stdout = stdout_backup
      end
    end
  end
end

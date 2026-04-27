require 'minitest/autorun'
require 'liquid'
require_relative '../_plugins/google-scholar-citations.rb'

class TestGoogleScholarCitations < Minitest::Test
  def setup
    # Clear the citations cache to ensure isolated tests
    Jekyll::GoogleScholarCitationsTag::Citations.clear
  end

  def test_rescue_error_returns_na
    tokens = Liquid::Tokenizer.new("")
    parse_context = Liquid::ParseContext.new
    tag = Jekyll::GoogleScholarCitationsTag.parse("google_scholar_citations", "scholar_id article_id", tokens, parse_context)
    context = Liquid::Context.new({}, {"scholar_id" => "123", "article_id" => "456"}, {})

    URI.stub :open, ->(*args) { raise StandardError.new("Network error") } do
      # Capture standard output since the plugin puts an error message
      out, err = capture_io do
        result = tag.render(context)
        assert_equal "N/A", result
      end
      assert_match(/Error fetching citation count for 456: StandardError - Network error/, out)
    end
  end
end

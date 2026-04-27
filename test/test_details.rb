require 'minitest/autorun'
require 'liquid'

# Mock Jekyll modules to avoid full dependency loading if not necessary
module Jekyll
  module Converters
    class Markdown; end
  end
  module Tags
  end
end

require_relative '../_plugins/details'

class TestDetailsTag < Minitest::Test
  def setup
    @converter = Minitest::Mock.new
    @site = Minitest::Mock.new
    @context = Liquid::Context.new({}, {}, { site: @site })
  end

  def test_render
    # Set up the inputs
    markup = 'My Caption '

    # We can parse it using Liquid::Template
    template = Liquid::Template.parse("{% details #{markup}%}This is the body content.{% enddetails %}")

    # Setup mocks
    @site.expect :find_converter_instance, @converter, [Jekyll::Converters::Markdown]

    # The converter converts the caption and the body
    @converter.expect :convert, '<p>My Caption</p>', [markup]
    @converter.expect :convert, '<p>This is the body content.</p>', ['This is the body content.']

    # Execute render
    result = template.render(@context)

    # Verify expectations
    @site.verify
    @converter.verify

    # Verify result
    assert_equal "<details><summary>My Caption</summary><p>This is the body content.</p></details>", result
  end

  def test_render_with_p_tags_in_caption
    markup = 'My **Caption** '
    template = Liquid::Template.parse("{% details #{markup}%}Body{% enddetails %}")

    @site.expect :find_converter_instance, @converter, [Jekyll::Converters::Markdown]

    # Simulate markdown converter putting <p> tags around caption
    @converter.expect :convert, '<p>My <strong>Caption</strong></p>', [markup]
    @converter.expect :convert, '<p>Body</p>', ['Body']

    result = template.render(@context)

    @site.verify
    @converter.verify

    # <p> and </p> should be stripped from caption
    assert_equal "<details><summary>My <strong>Caption</strong></summary><p>Body</p></details>", result
  end

  def test_render_with_empty_caption
    markup = ''
    template = Liquid::Template.parse("{% details %}Body{% enddetails %}")

    @site.expect :find_converter_instance, @converter, [Jekyll::Converters::Markdown]

    @converter.expect :convert, '', [markup]
    @converter.expect :convert, '<p>Body</p>', ['Body']

    result = template.render(@context)

    @site.verify
    @converter.verify

    assert_equal "<details><summary></summary><p>Body</p></details>", result
  end
end

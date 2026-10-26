require 'minitest/autorun'
require 'jekyll'
require_relative '../_plugins/details'

class TestDetailsTag < Minitest::Test
  def setup
    @site = Jekyll::Site.new(Jekyll.configuration({
      "source" => File.expand_path("..", __dir__),
      "destination" => File.expand_path("../_site", __dir__)
    }))
    @context = Liquid::Context.new({}, {}, { site: @site })
  end

  def test_details_tag_rendering
    template = Liquid::Template.parse("{% details My Caption %}Here is the body.{% enddetails %}")
    result = template.render(@context)

    expected = "<details><summary>My Caption</summary><p>Here is the body.</p>\n</details>"
    assert_equal expected, result
  end

  def test_details_tag_with_markdown_caption
    template = Liquid::Template.parse("{% details **Bold** Caption %}Some body{% enddetails %}")
    result = template.render(@context)

    expected = "<details><summary><strong>Bold</strong> Caption</summary><p>Some body</p>\n</details>"
    assert_equal expected, result
  end

  def test_details_tag_with_markdown_body
    template = Liquid::Template.parse("{% details Caption %}\n# Heading 1\n\nSome **bold** text.\n{% enddetails %}")
    result = template.render(@context)

    expected = "<details><summary>Caption</summary>\n<h1 id=\"heading-1\">Heading 1</h1>\n\n<p>Some <strong>bold</strong> text.</p>\n</details>"
    assert_equal expected, result
  end
end

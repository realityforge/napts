require File.dirname(__FILE__) + '/../test_helper'
require 'text_formatter'

class TextFormatterTest < Test::Unit::TestCase
  def test_formatted_content
    assert_equal('<h1>blah</h1>',TextFormatter.formatted_content(TextFormatter::RedClothFormat, '*'))
  end
end

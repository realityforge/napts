require File.dirname(__FILE__) + '/../test_helper'
require 'text_formatter'

class TextFormatterTest < Test::Unit::TestCase
  def test_formatted_content
    assert_equal('<h1>red</h1>',TextFormatter.formatted_content(TextFormatter::RedClothFormat, 'h1. red'))
    assert_equal('<p><strong>blue</strong></p>', TextFormatter.formatted_content(TextFormatter::BlueClothFormat, '**blue**'))
    assert_equal('&#8220;pants&#8221;', TextFormatter.formatted_content(TextFormatter::RubyPantsFormat, '"pants"'))
    assert_equal( 'bob', TextFormatter.formatted_content(TextFormatter::PlainFormat, 'bob'))
    assert_raise( RuntimeError ) {  TextFormatter.formatted_content('NeridaSmellsFunny', 'bob') }
  end
end

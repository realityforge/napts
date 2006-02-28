require File.dirname(__FILE__) + '/../test_helper'

class CssTest < Test::Unit::TestCase
  def test_layout_css
    assert_valid_css(File.open("#{RAILS_ROOT}/public/stylesheets/layout.css",'rb').read)
  end

  def test_standard_css
    assert_valid_css(File.open("#{RAILS_ROOT}/public/stylesheets/standard.css",'rb').read)
  end
end

require File.dirname(__FILE__) + '/../test_helper'

class CssTest < Test::Unit::TestCase
  assert_valid_css_files 'layout', 'standard'
end

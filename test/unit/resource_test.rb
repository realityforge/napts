require File.dirname(__FILE__) + '/../test_helper'


class FakeFile
  attr_accessor :original_filename, :content_type, :read
  def initialize(original_filename, content_type, read)
    @original_filename = original_filename
    @content_type = content_type
    @read = read
  end
end

class ResourceTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_base_part_of
    assert_equal('file.txt', Resource.base_part_of('/a/b/c/file.txt'))
    assert_equal('file.txt', Resource.base_part_of('C:\a\file.txt'))
  end

  def test_data
    resource = Resource.new(:description => 'description', :data => FakeFile.new('C:\a\file.txt','text/plain','ABCDEFGHIJKLMNOPQRSTUVWXYZ'))
    assert_equal('description', resource.description)
    assert_equal('file.txt', resource.name)
    assert_equal('text/plain', resource.content_type)
    assert_equal('ABCDEFGHIJKLMNOPQRSTUVWXYZ', resource.resource_data.data)
  end
end

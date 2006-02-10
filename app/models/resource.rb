class Resource < ActiveRecord::Base
  has_one( :resource_data, :dependent => true )
  has_and_belongs_to_many( :questions )
  validates_presence_of( :content_type, :name )
  attr_accessible :description, :data
  
  def data=(data_field)
    self.name = base_part_of(data_field.original_filename)
    self.content_type = data_field.content_type.chomp
    self.resource_data =
        ResourceData.new( :resource_id => id, :data => data_field.read )
  end
  
  def base_part_of( file_name )
    name = File.basename(file_name)
    name.gsub(/[^\w._-]/,'')
  end
end

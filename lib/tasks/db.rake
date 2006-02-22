task :reset_db_with_images => :reset_db do
  STDERR.puts "Loading image data"
  r = Resource.new
  r.name = 'greenofb.jpg'
  r.description = 'Pauls picture'
  r.content_type = 'image/jpeg'
  r.subject_group_id = 1
  r.save!
  ResourceData.create!(:resource_id => r.id, :data => File.new("#{RAILS_ROOT}/test/fixtures/greenofb.jpg","rb").read)
  Question.find(1).resources << r
end

desc "Cleanup temporary files"
task :cleanup => :environment do
  Dir["#{RAILS_ROOT}/**/*.*~"].each {|file| File.delete(file)}
  Dir["#{RAILS_ROOT}/temp/**/*.*"].each {|file| File.delete(file)}
  Dir["#{RAILS_ROOT}/log/*.*"].each {|file| File.delete(file)}
end

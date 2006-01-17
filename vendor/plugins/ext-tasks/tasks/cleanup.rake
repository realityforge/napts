desc "Cleanup temporary files"
task :cleanup => :environment do
  Dir["#{RAILS_ROOT}/**/*.*~"].each {|file| File.delete(file)}
  Dir["#{RAILS_ROOT}/temp/**/*.*"].each {|file| File.delete(file)}
  FileList["log/*.log"].each do |log_file|
    f = File.open(log_file, "w")
    f.close
  end
end

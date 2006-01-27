desc "Cleanup temporary files"
task :cleanup => :environment do
  Dir["#{RAILS_ROOT}/**/*.*~"].each {|file| File.delete(file)}
  Dir.glob("#{RAILS_ROOT}/temp/*") {|f| FileUtils.rm_r(f, :force => true) unless f == '.svn'}
  FileList["log/*.log"].each do |log_file|
    f = File.open(log_file, "w")
    f.close
  end
end

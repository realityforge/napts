desc "Reset Database structure"
task :reset_db_structure => :environment do
  require 'active_record/fixtures'
  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)

  database = ActiveRecord::Base.configurations[RAILS_ENV]['database']

  ActiveRecord::Base.connection.execute("DROP DATABASE #{database};")
  ActiveRecord::Base.connection.execute("CREATE DATABASE #{database};")
  ActiveRecord::Base.connection.execute("USE #{database};")

  IO.readlines("db/create.mysql.sql").join.split(";").each do |command|
    ActiveRecord::Base.connection.execute("#{command};") unless command.gsub(/\s*/, '') .empty?
  end
end


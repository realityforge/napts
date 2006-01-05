desc 'Dump a database to yaml fixtures. '
task :dump_fixtures => :environment do
  path = ENV['FIXTURE_DIR'] || "#{RAILS_ROOT}/data"

  # To get list of tables in postgres
  # select_values(<<-end_sql
  #  SELECT c.relname
  # FROM pg_class c
  #   LEFT JOIN pg_roles r     ON r.oid = c.relowner
  #   LEFT JOIN pg_namespace n ON n.oid = c.relnamespace
  # WHERE c.relkind IN ('r','')
  #   AND n.nspname IN ('myappschema', 'public')
  #   AND pg_table_is_visible(c.oid)
  # end_sql

  # MySQL:   ActiveRecord::Base.connection.select_values('show tables')
  # SQLite:  ActiveRecord::Base.connection.select_values('.table')

  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
  ActiveRecord::Base.connection.select_values('show tables').each do |table_name|
    i = 0
    File.open("#{path}/#{table_name}.yml", 'wb') do |file|
      file.write ActiveRecord::Base.connection.select_all("SELECT * FROM #{table_name}").inject({}) { |hash, record|
        hash["#{table_name}_#{i += 1}"] = record
        hash
      }.to_yaml
    end
  end
end

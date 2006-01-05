desc "Run the continuous integration action"
task :cia => [:reset_test_db, :test_units, :test_functional] do
end

desc "Reset Test Database"
task :reset_test_db => :environment do
  do_reset_db(:test)
end

desc "Reset Database"
task :reset_db => :environment do
  do_reset_db(RAILS_ENV.to_sym)
end

def do_reset_db_structure(env)
  ActiveRecord::Base.establish_connection(env)
  ActiveRecord::Migrator.migrate("db/migrate/",0)
  ActiveRecord::Migrator.migrate("db/migrate/",nil)
end

def do_reset_db_data(env)
  require 'active_record/fixtures'
  ActiveRecord::Base.establish_connection(env)
  path = ENV['FIXTURE_DIR'] || "#{RAILS_ROOT}/test/fixtures"
  Fixtures.create_fixtures(path, OrderedTables)
end

def do_reset_db(env)
  do_reset_db_structure(env)
  do_reset_db_data(env)
end

module Rake
  class Task
    def remove_prerequisite(task_name)
      name = task_name.to_s
      @prerequisites.delete(name)
    end
  end
end

Rake::Task.lookup(:test_units).remove_prerequisite(:prepare_test_database)
Rake::Task.lookup(:test_functional).remove_prerequisite(:prepare_test_database)

Rake::Task.lookup(:test_units).enhance([:environment])
Rake::Task.lookup(:test_functional).enhance([:environment])

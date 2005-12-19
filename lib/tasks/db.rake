OrderedTables = [ :users, :subjects, :quizzes, :questions, :quiz_items, :answers, :quiz_attempts, :quiz_responses ].collect {|x| x.to_s }

desc "Reset Database data to that in fixtures"
task :reset_db_data => :environment do
  require 'active_record/fixtures'
  ActiveRecord::Base.establish_connection(RAILS_ENV.to_sym)
  path = ENV['FIXTURE_DIR'] || 'test/fixtures'
  Fixtures.create_fixtures(path, OrderedTables)
end

desc "Reset Database structure"
task :reset_db_structure => :environment do
  do_reset_db_structure(RAILS_ENV.to_sym)
end

desc "Reset Test Database structure"
task :reset_test_db_structure => :environment do
  do_reset_db_structure(:test)
end

desc "Reset Database"
task :reset_db => [ :reset_db_structure, :reset_db_data ] do
end

def do_reset_db_structure(env)
  ActiveRecord::Base.establish_connection(env)
  ActiveRecord::Migrator.migrate("db/migrate/",0)
  ActiveRecord::Migrator.migrate("db/migrate/",nil)
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

desc "Run the continuous integration action"
task :cia => [:reset_test_db_structure, :test_units, :test_functional] do
end

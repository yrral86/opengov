require 'rake/testtask'

APP_BASE = File.dirname(File.expand_path(__FILE__))

Rake::TestTask.new(:do_test) do |t|
  `mkdir -p sockets/test`
  `./componentmanager.rb start --test`
  sleep 1.0
  t.test_files = FileList['tests/test*.rb']
  t.verbose = true
end

task :test => :do_test do
  `./componentmanager.rb stop`
end

task :doc do
  `rm -rf doc/`
  `rdoc1.9.1 lib`
end

namespace :db do
  task :ar_init do
    # Load the database config
    require 'active_record'
    database_yml = YAML::load(File.open(APP_BASE + "/db/config.yml"))['default']
    current_env = ENV['ENV'] || "development"
    ActiveRecord::Base.establish_connection(database_yml[current_env])
    # set a logger for STDOUT
    ActiveRecord::Base.logger = Logger.new(STDOUT)
  end

  desc "Migrate the database through scripts in db/migrate. Target specific version with VERSION=x. Turn off output with VERBOSE=false."
  task :migrate => :ar_init do
    ActiveRecord::Migration.verbose = ENV["VERBOSE"] ? ENV["VERBOSE"] == "true" : true
    ActiveRecord::Migrator.migrate(APP_BASE + "/db/migrations/", ENV["VERSION"] ? ENV["VERSION"].to_i : nil)
    Rake::Task["db:schema:dump"].invoke if ActiveRecord::Base.schema_format == :ruby
  end

  namespace :schema do
    desc "Create a db/ar_schema.rb file that can be portably used against any DB supported by AR"
    task :dump => :ar_init do
      require 'active_record/schema_dumper'
      File.open(ENV['SCHEMA'] || APP_BASE + "/db/schema.rb", "w") do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end

    desc "Load a ar_schema.rb file into the database"
    task :load => :ar_init do
      file = ENV['SCHEMA'] || APP_BASE + "/db/schema.rb"
      load(file)
    end
  end

  desc "Create a new migration"
  task :new_migration do |t|
    unless migration = ENV['name']
      puts "Error: must provide name of migration to generate."
      puts "For example: rake #{t.name} name=add_field_to_form"
      abort
    end

    class_name = migration.split('_').map{|s| s.capitalize }.join
    file_contents = <<eof
class #{class_name} < ActiveRecord::Migration
  def self.up
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
eof
    migration_path = "db/migrations"
    FileUtils.mkdir_p(migration_path) unless File.exist?(migration_path)
    file_name  = "#{migration_path}/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}_#{migration}.rb"

    File.open(file_name, 'w'){|f| f.write file_contents }

    puts "Created migration #{file_name}"
  end
end

require 'rake/testtask'
require 'cucumber/rake/task'
require 'active_record'
require 'rack/logger'

APP_BASE = File.dirname(File.expand_path(__FILE__))
$:.unshift APP_BASE + '/lib'

Rake::TestTask.new(:do_test) do |t|
  t.test_files = FileList['tests/test*.rb']
end

Cucumber::Rake::Task.new(:features) do |t|
  t.cucumber_opts = "-f progress"
end

task :setup_test do
  module MiniTest
    class Unit
      def self.disable_autorun
          @@installed_at_exit = true
      end
    end
  end

  MiniTest::Unit.disable_autorun

  require 'derailed/testcase'
  `mkdir -p sockets/test`
  puts "Starting OpenGov..."
  `./control.rb -tm start`
  Derailed::TestCase.socket_wait
  puts "OpenGov started."
end

task :teardown_test do
  puts "Stopping OpenGov"
  `./control.rb -tm stop`
end

task :test => [:setup_test, :features, :do_test, :teardown_test] do

end


task :doc do
  `rm -rf doc/`
  `rdoc -d lib`
end

desc "Create a new component"
task :new_component do |t|
  unless component = ENV['name']
    puts "Error: must provide name of component to generate."
    puts "For example: rake #{t.name} name=Authenticator"
    abort
  end

  component = component.capitalize

  `git diff --exit-code`
  unless $?.to_i == 0
    puts "Error: git repository has outstanding changes, please commit"
    abort
  end

  folder = "components-available/#{component.downcase}"
  active_link = "components-enabled/#{component.downcase}"
  config_file = <<eof
name: #{component}
eof

  controller_file = <<eof
class #{component}Controller < Derailed::Component::Controller

end
eof

  puts "creating directory #{folder}"
  FileUtils.mkdir_p(folder) unless File.exist?(folder)
  config_fn = "#{folder}/config.yml"
  controller_fn = "#{folder}/controller.rb"
  puts "writing #{config_fn}"
  File.open(config_fn, "w") { |f| f.write config_file }
  puts "writing #{controller_fn}"
  File.open(controller_fn, "w") { |f| f.write controller_file }
  puts "enabling component (creating symlink)"
  File.symlink("../#{folder}", active_link)
  puts "Created component #{component}"
  `git add #{folder} #{active_link}`
  `git commit -am 'added component #{component}'`
  puts 'Commited to repository'
end

namespace :db do
  task :ar_init do
    require 'derailed/config'
    # Load the database config
    config = Derailed::Config.db_config('default')
    ActiveRecord::Base.establish_connection(config)
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

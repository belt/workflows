# frozen_string_literal: true
require 'sequel'
namespace :db do
  Sequel.extension :migration
  DB = ENV.key?('DATABASE_URL') ? Sequel.connect(ENV['DATABASE_URL']) : nil

  desc 'Prints current schema version'
  task :version do
    version = DB.tables.include?(:schema_info) ? DB[:schema_info].first[:version] : 0
    puts "Schema Version: #{version}"
  end

  desc 'Perform migration up to latest migration available'
  task :migrate do
    Sequel::Migrator.run DB, 'db/migrate'
    Rake::Task['db:version'].execute
  end

  desc 'Perform rollback to specified target or full rollback as default'
  task :rollback, :target do |_t, args|
    args.with_defaults target: 0

    Sequel::Migrator.run DB, 'db/migrate', target: args[:target].to_i
    Rake::Task['db:version'].execute
  end

  desc 'Perform migration reset (full rollback and migration)'
  task :reset do
    Sequel::Migrator.run DB, 'db/migrate', target: 0
    Sequel::Migrator.run DB, 'db/migrate'
    Rake::Task['db:version'].execute
  end
end

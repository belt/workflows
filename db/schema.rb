# frozen_string_literal: true
Sequel.migration do
  change do
    create_table :schema_migrations do
      primary_key :filename
      column :filename, 'varchar(255)', null: false
    end

    create_table :workflows do
      primary_key :id, type: 'int(11)'
      column :name, 'varchar(255)'
      column :app_route, 'varchar(255)'
      column :flow_group, 'varchar(255)'
    end
  end
end
Sequel.migration do
  change do
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('001_schema_migrations.rb')"
    self << "INSERT INTO `schema_migrations` (`filename`) VALUES ('20150127002700_create_workflows.rb')"
  end
end

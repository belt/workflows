Sequel.migration do
  change do
    create_table :workflows do
      primary_key :id
      String :name
      String :app_route
      String :flow_group
    end
  end
end

# This file should contain all the record creation needed to seed the database
# with its default values.  The data can then be loaded with the rake db:seed
# (or created alongside the db with db:setup).
Workflow.find_or_create flow_group: '/', name: 'Infinite Loop',
                        app_route: '/'

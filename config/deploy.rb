# grep capistrano-3 Gemfile.lock and ensure this matches
# config valid only for capistrano-3.7.2
lock '3.7.2'

set :application, 'workflows'
set :repo_url, 'git@github.com:belt/workflows.git'
set :deploy_to, "~deploy/#{fetch :application}"
set :bundle_without, %w(development test windows darwin).join(' ')
set :linked_files, %w(.rbenv-vars config/database.yml config/secrets.yml)
set :linked_dirs, %w(tmp log)
set :filter, role: %w(web)
set :passenger_roles, :web
set :format, :airbrussh

# policy
set :rbenv_type, :user

# disable assets if this is an API-only project
# Rake::Task['deploy:compile_assets'].clear_actions
# Rake::Task['deploy:normalize_assets'].clear_actions

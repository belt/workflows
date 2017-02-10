source 'https://rubygems.org'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '~> 4.2.0'
gem 'mysql2'
gem 'rest-client'
gem 'sequel-rails'
gem 'responders'

gem 'haml-rails'
gem 'sass-rails'
gem 'uglifier'
gem 'coffee-rails'
gem 'bootstrap'
gem 'rails-assets-tether'
gem 'draper'

# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
gem 'jquery-ui-rails'
#gem 'turbolinks'
gem 'jbuilder'
gem 'sdoc', group: :doc

#  gem 'activeadmin'
#  gem "meta_search" #, '>= 1.1.0.pre'

gem 'config'
gem 'yajl-ruby', require: 'yajl/json_gem'
gem 'concurrent-ruby'

group :development do
  gem 'overcommit', require: false

  gem 'capistrano', require: false
  gem 'capistrano-rails', require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rbenv', require: false
  gem 'capistrano-rbenv-install', require: false
  gem 'capistrano-rbenv-vars', require: false
  gem 'airbrussh', require: false

  # Until the code from https://github.com/capistrano/passenger/issues/40
  # gets tagged
  gem 'capistrano-passenger', require: false
end

group :development, :test do
  gem 'pry-rescue'
  gem 'spring'
end

group :development, :test, :ci do
  gem 'brakeman', require: false, github: 'presidentbeef/brakeman'
  gem 'simplecov', require: false
  gem 'metric_fu'
  gem 'rubocop', require: false
  gem 'fukuzatsu', require: false

  gem 'rspec-rails'
  gem 'faker'
end

group :development, :test, :ci, :integration do
  gem 'rails-perftest', require: false
  gem 'ruby-prof', require: false

  gem 'pry-byebug'
  gem 'pry-bond'
  gem 'pry-stack_explorer'
  gem 'interactive_editor'
  gem 'awesome_print'
  gem 'did_you_mean'
  gem 'webmock'
  gem 'hashdiff'
end

group :test, :ci do
  gem 'capybara'
  gem 'database_cleaner'
  gem 'timecop'
  gem 'shoulda-matchers', require: false
  gem 'valid_attribute'
end

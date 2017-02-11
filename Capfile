# frozen_string_literal: true
# Load DSL and set up stages
require 'capistrano/setup'

# Include default deployment tasks
require 'capistrano/deploy'

require 'capistrano/rbenv'
require 'capistrano/rbenv_install'
require 'capistrano/rbenv_vars'
require 'capistrano/bundler'
require 'capistrano/rails/assets'
#require 'capistrano/rails/migrations'
require 'capistrano/passenger'
require 'airbrussh/capistrano'

# [Deprecation Notice] capistrano ~> 3.7.2 will not load the Git SCM
# plugin by default
require 'capistrano/scm/git'
install_plugin Capistrano::SCM::Git

# Load custom tasks from `lib/capistrano/tasks' if there are any defined
Dir.glob('lib/capistrano/tasks/*.rake').each {|rtask| import rtask}

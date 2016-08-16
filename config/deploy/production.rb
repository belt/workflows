set :log_level, :error # :debug :info :error
set :rbenv_ruby, '2.3.0'
set :branch, :master
set :rails_env, :production
set :default_env, fetch(:default_env).merge(CONFIGURE_OPTS: '--disable-install-doc')

set :linked_files, fetch(:linked_files) + ["config/settings/#{fetch(:rails_env)}.yml"]
set :linked_files, fetch(:linked_files) + ['config/initializers/gc.rb']

set :user, 'vagrant'
set :ssh_options, {forward_agent: true, port: 2222,
                   keys: ['~/.vagrant.d/insecure_private_key']}

server 'localhost', user: 'deploy', roles: %w(web)
server 'localhost', user: 'deploy', roles: %w(db), primary: true

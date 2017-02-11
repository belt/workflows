# frozen_string_literal: true
set :log_level, :debug # :debug :info :error
set :rbenv_ruby, '2.3.3'
set :branch, :next
set :rails_env, :integration
set :default_env, fetch(:default_env).merge(CONFIGURE_OPTS: '--disable-install-doc')

set :linked_files, fetch(:linked_files) + ["config/settings/#{fetch(:rails_env)}.yml"]
set :linked_files, fetch(:linked_files) + ['config/initializers/gc.rb']

vagrant_ssh_config = `vagrant ssh-config`.split("\n")[1..-1].map(&:strip)
vagrant_ssh_config = vagrant_ssh_config.each_with_object({}) do |obj, conf|
  key, val = obj.split(/\s+/, 2).map(&:strip)
  conf[key] = val
  conf
end

# TODO: figure out why port-forwarding is considered off by vagrant
set :user, vagrant_ssh_config['User']
set :ssh_options, {forward_agent: 'yes', port: vagrant_ssh_config['Port'],
                   keys: ['packer/salt/keys/id_rsa.vagrant.workflows']}

server 'localhost', user: 'deploy', roles: %w(web)
server 'localhost', user: 'deploy', roles: %w(db), primary: true

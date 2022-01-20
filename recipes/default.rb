#
# Cookbook:: errbit
# Recipe:: default
#
# Copyright:: 2021, The Authors, All Rights Reserved.



include_recipe 'git'
include_recipe 'ruby'
include_recipe 'mongo'

#package 'mc'
#package 'build-essential'
#package 'gnupg'

hostname node.default["hostname"]

execute "clone_errbit_repo" do
  login true
  cwd "#{node.default["errbit_home"]}"
  command "git clone https://github.com/errbit/errbit.git #{node.default["errbit_home"]}/app"
  user node.default["errbit_user"]
  action :run
end

execute "install_bundler" do
  login true
  cwd "#{node.default["errbit_home"]}/app"
  command "~/.rbenv/shims/gem install bundler -v  \"$(grep -A 1 \"BUNDLED WITH\" Gemfile.lock | tail -n 1)\""
  user node.default["errbit_user"]
  action :run
end

execute "bundle install" do
  login true
  cwd "#{node.default["errbit_home"]}/app"
  command "~/.rbenv/shims/bundle install"
  user node.default["errbit_user"]
  action :run
end

execute "bundle_exec" do
  login true
  cwd "#{node.default["errbit_home"]}/app"
  command "ERRBIT_ADMIN_EMAIL=#{node.default["errbit_admin_email"]} ERRBIT_ADMIN_PASSWORD=#{node.default["errbit_admin_password"]} ERRBIT_HOST=#{node.default["erbit_host"]} ~/.rbenv/shims/bundle exec ~/.rbenv/shims/rake errbit:bootstrap"
  user node.default["errbit_user"]
  action :run
end

execute "chown_to_errbit_user" do
  command "chown -R #{node.default["errbit_user"]}:#{node.default["errbit_user"]} #{node.default["errbit_home"]}"   
  user "root"
  action :run
end

systemd_unit 'errbit.service' do
  content({ Unit: {
            Description: 'errbit server',
          },
          Service: {
            User: node.default["errbit_user"],
            WorkingDirectory: "#{node.default["errbit_home"]}/app",
            ExecStart: "/bin/bash -c \"cd #{node.default["errbit_home"]}/app; #{node.default["errbit_home"]}/.rbenv/shims/bundle exec #{node.default["errbit_home"]}/app/bin/rails server -b #{node.default['errbit_litener_address']} -p #{node.default['errbit_litener_port']}\"",
            Restart: 'always',
          },
          Install: {
            WantedBy: 'multi-user.target',
          } })
  action [:create, :enable, :start]
end
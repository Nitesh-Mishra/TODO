require "bundler/capistrano"
require "rvm/capistrano"
require 'capistrano/sidekiq'

set :whenever_command, "bundle exec whenever"
require "whenever/capistrano"

set :application, "hash_tag_loyalty"
set :repository, "git@github.com:Nitesh-Mishra/TODO.git"
# set :server_name, "52.74.11.152"
set :user, "ubuntu"
set :scm_passphrase, ""
set :runner, "ubuntu"
#set :password, "Qwerty123!"
set :deploy_via, :export
set :scm, "git"
set :ssh_options, { forward_agent: true }
ssh_options[:keys] = "~/.ssh/project.pem"
set :branch, "master"
set :base_path, "/home/ubuntu/sites"
set :deploy_to, "/home/ubuntu/sites/#{application}"
# set :apache_site_folder, "/etc/nginx/sites-enabled"
set :migrate_target, :current

set :db_user, "root"
set :db_pass, "root123"

set :rvm_ruby_string, ENV["GEM_HOME"].gsub(/.*\//,"")
set :rvm_ruby_string, "ruby-1.9.3-p551"
set :rvm_type, :user  # is default

set :sync_backups, 3
set :stage, :production
set :sync_directories, ["public/system"]
set :sidekiq_config, "#{current_path}/config/sidekiq.yml"

# set :sidekiq_role, :app
# set :sidekiq_config, "#{current_path}/config/sidekiq.yml"
# set :sidekiq_env, 'production'

role :web, []
#role :app, server_name
role :db,  [], primary: true

ssh_options[:paranoid] = false
default_run_options[:pty] = true

task :create_log_share do
  run "mkdir -p #{shared_path}/log"
end
before 'deploy:update', :create_log_share

after 'deploy:update_code' do
  # run "cd #{release_path}; RAILS_ENV=production rake assets:precompile"
  run "cd #{release_path}; RAILS_ENV=production rake db:migrate"
  run "mkdir -p #{release_path}/tmp/cache;"
  run "chmod -R 777 #{release_path}/tmp/cache;"
  run "mkdir -p #{release_path}/public/uploads;"
  run "chmod -R 777 #{release_path}/public/uploads"
  #run "#{try_sudo} mkdir -p #{release_path}/public/system;"
  #run "chmod -R 777 #{release_path}/public/system"
end

task :add_default_hooks do
  after 'deploy:starting', 'sidekiq:quiet'
  after 'deploy:updated', 'sidekiq:stop'
  after 'deploy:reverted', 'sidekiq:stop'
  after 'deploy:published', 'sidekiq:start'
end

namespace :deploy do
  task :restart, :roles => :app, :except => { :no_release => true } do
    run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
  end
end


# set :application, "set your application name here"
# set :repository,  "set your repository location here"

# set :scm, :git # You can set :scm explicitly or Capistrano will make an intelligent guess based on known version control directory names
# Or: `accurev`, `bzr`, `cvs`, `darcs`, `git`, `mercurial`, `perforce`, `subversion` or `none`

# role :web, "your web-server here"                          # Your HTTP server, Apache/etc
# role :app, "your app-server here"                          # This may be the same as your `Web` server
# role :db,  "your primary db-server here", :primary => true # This is where Rails migrations will run
# role :db,  "your slave db-server here"

# if you want to clean up old releases on each deploy uncomment this:
# after "deploy:restart", "deploy:cleanup"

# if you're still using the script/reaper helper you will need
# these http://github.com/rails/irs_process_scripts

# If you are using Passenger mod_rails uncomment this:
# namespace :deploy do
#   task :start do ; end
#   task :stop do ; end
#   task :restart, :roles => :app, :except => { :no_release => true } do
#     run "#{try_sudo} touch #{File.join(current_path,'tmp','restart.txt')}"
#   end
# end
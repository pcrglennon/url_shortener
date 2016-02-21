role :docker, %w{docker-user@104.236.201.96}

server '104.236.201.96', user: 'docker-user', roles: %w{docker}

namespace :docker do
  desc 'Replace linked files with copies of their targets, so Docker can add them properly'
  task :copy_shared_files do
    on roles(:docker) do |host|
      within current_path do
        fetch(:linked_files, []).each do |file|
          execute 'cp', '--remove-destination', "$(readlink #{file})", file
        end
      end
    end
  end

  task :setup_container => :copy_shared_files do
    on roles(:docker) do |host|
      within current_path do
        execute 'docker-compose', 'build'
        execute 'docker-compose',
                '-f', 'docker-compose.production.yml',
                '-p', 'url_shortener',
                'up', '-d'
      end
    end
  end
end

after 'deploy:finishing', 'docker:setup_container'

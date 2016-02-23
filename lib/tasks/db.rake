DOCKER_MACHINE_NAME   = "default"
DOCKER_CONTAINER_NAME = "scprv4-#{Rails.env}"
DOCKER_MACHINE_ENV = "eval $(docker-machine env #{DOCKER_MACHINE_NAME})"

def shell_command &block
  cmds = []
  yield cmds
  cmds.each do |c| 
    IO.popen("#{DOCKER_MACHINE_ENV} && #{c}").each do |line|
      puts line
    end
  end
end

namespace :db do
  task :pull do
    token = ARGV[1]
    shell_command do |cmds|
      machine = `docker-machine ls | grep #{DOCKER_MACHINE_NAME}`
      if machine.empty?
        cmds << "docker-machine create --driver virtualbox --virtualbox-memory 2048 #{DOCKER_MACHINE_NAME}"
      end
      cmds << "docker-machine start #{DOCKER_MACHINE_NAME}"
      cmds << "docker pull scpr/restore-percona-backup"
      cmds << "echo '###### You may want to detach the process at this point in your shell (Ctrl+z and then execute `bg`) ######'"
      cmds << "docker stop -f #{DOCKER_CONTAINER_NAME}"
      cmds << "docker rm -f #{DOCKER_CONTAINER_NAME}"
      cmds << "docker run -p 3306:3306 --name #{DOCKER_CONTAINER_NAME} scpr/restore-percona-backup #{token}"
    end
  end
  task :start do
    container_id = `#{DOCKER_MACHINE_ENV} && docker ps --filter "status=exited" | grep #{DOCKER_CONTAINER_NAME}`.match(/^(\w*)\ +/).try(:[], 0)
    puts `#{DOCKER_MACHINE_ENV} && docker start #{container_id}`
  end
  task :stop do
    container_id = `#{DOCKER_MACHINE_ENV} && docker ps | grep #{DOCKER_CONTAINER_NAME}`.match(/^(\w*)\ +/).try(:[], 0)
    puts `#{DOCKER_MACHINE_ENV} && docker stop #{container_id}`
  end
  task :containers do
    puts "-----STARTED-----"
    puts `docker ps`
    puts "-----STOPPED-----"
    puts `docker ps --filter "status=exited"`
  end
end
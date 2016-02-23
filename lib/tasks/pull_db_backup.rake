  # def cmd cmds, daemon: false
  #   unless daemon
  #     IO.popen(cmds).each do |line|
  #       puts line
  #     end
  #   else
  #     pid = spawn(cmds)
  #     Process.detach(pid)
  #   end
  # end



def shell_command &block
  cmds = []
  yield cmds
  IO.popen(cmds.join(" && ")).each do |line|
    puts line
  end
end

namespace :pull_db_backup do
  puts "Enter token:"
  token = STDIN.gets.chomp
  shell_command do |cmds|
    machine = `docker-machine ls | grep scprv4`
    if machine.empty?
      cmds << "docker-machine create --driver virtualbox scprv4"
    end
    cmds << "eval $(docker-machine env scprv4)"
    cmds << "docker pull scpr/restore-percona-backup"
    cmds << "docker run --rm -p 3306:3306 scpr/restore-percona-backup #{token}"
  end
end
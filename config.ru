# This file is used by Rack-based servers to start the application.

`eval $(docker-machine env default)`
require ::File.expand_path('../config/environment',  __FILE__)
run Scprv4::Application

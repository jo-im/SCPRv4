# This file is used by Rack-based servers to start the application.

`eval $(docker-machine env scprv4)`
require ::File.expand_path('../config/environment',  __FILE__)
run Scprv4::Application

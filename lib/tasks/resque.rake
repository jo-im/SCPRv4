require 'resque/pool/tasks'

namespace :resque do
  namespace :pool do
    task :setup do
      begin
        ActiveRecord::Base.connection.disconnect!
      rescue ActiveRecord::ConnectionNotEstablished
        # Nothing to do.
      end

      Resque::Pool.after_prefork do |job|
        ActiveRecord::Base.establish_connection
      end
    end
  end
end

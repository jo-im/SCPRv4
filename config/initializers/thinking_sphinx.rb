# https://github.com/pat/thinking-sphinx/issues/635
if defined?(ThinkingSphinx::ActiveRecord::DatabaseAdapters::MySQLAdapter)
  class ThinkingSphinx::ActiveRecord::DatabaseAdapters::MySQLAdapter
    def time_zone_query_pre
      []
    end
  end
end

if defined?(ThinkingSphinx::MysqlAdapter)
  class ThinkingSphinx::MysqlAdapter
    def utc_query_pre
      ""
    end
  end
end

if defined?(ThinkingSphinx::RakeInterface)
  class ThinkingSphinx::RakeInterface
    def index(reconfigure = true, verbose = true)
      configure if reconfigure

      dir = configuration.indices_location
      FileUtils.mkdir_p(dir) unless File.exists?(dir)
      ThinkingSphinx.before_index_hooks.each { |hook| hook.call }
      controller.index :verbose => verbose
    end
  end
end

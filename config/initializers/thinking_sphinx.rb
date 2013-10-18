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

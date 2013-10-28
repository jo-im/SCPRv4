class ThinkingSphinx::RakeInterface
  def index(reconfigure = true, verbose = true)
    configure if reconfigure

    dir = configuration.indices_location
    FileUtils.mkdir_p(dir) unless File.exists?(dir)
    ThinkingSphinx.before_index_hooks.each { |hook| hook.call }
    controller.index :verbose => verbose
  end
end

# Thinking Sphinx 3 removed this method, but we're still using it.
class String
  def to_crc32
    Zlib.crc32(self)
  end
end

ThinkingSphinx::SphinxQL.functions!
ThinkingSphinx::Middlewares::DEFAULT.delete ThinkingSphinx::Middlewares::UTF8

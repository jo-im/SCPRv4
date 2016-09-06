require "#{Rails.root}/lib/embeditor/processor"
module Filter
  class EmbeditorFilter < HTML::Pipeline::Filter
    def call
      embeditor = Embeditor::Processor.new
      @doc = Nokogiri::HTML.fragment embeditor.process doc.to_s
      doc
    ensure
      embeditor.close
    end
  end
end
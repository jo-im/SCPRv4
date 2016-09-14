require "#{Rails.root}/lib/embeditor/processor"
module Filter
  class EmbeditorFilter < HTML::Pipeline::Filter
    def call
      embeditor = Embeditor::Processor.new
      Nokogiri::HTML.fragment embeditor.process doc.to_s
    ensure
      embeditor.close
    end
  end
end
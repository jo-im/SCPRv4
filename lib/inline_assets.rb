require 'nokogiri'

module InlineAssets
  class AssetData
    ## This is to normalize the data we get from a response
    ## to something we might expect from a normal content
    ## asset from an article.  That way we can use the same
    ## partials.
    attr_accessor :full, :caption, :owner, :title, :raw_data
    def initialize asset_data
      @full     = OpenStruct.new({url: asset_data["urls"]["full"]})
      @caption  = asset_data["caption"]
      @owner    = asset_data["owner"]
      @title    = asset_data["title"]
      @raw_data = asset_data
    end
    def asset
      self
    end
  end
  class Parser
    def initialize body
      body.respond_to?(:body) ? (@body = body.body) : (@body = body)
      @cssPath = "img.inline-asset[data-asset-id]"
    end
    def document
      doc = Nokogiri::HTML(@body)
    end
    def map cssPath=@cssPath, &block
      doc = document
      doc.css(cssPath).each do |placeholder|
        change = yield(placeholder, doc)
        if change != placeholder && change != nil
          placeholder.replace Nokogiri::HTML(change).css("body").children
        end
      end
      doc
    end
    def asset_ids css_path=@cssPath
      document.css(cssPath).map{|placeholder| placeholder.attr("data-asset-id").to_s}
    end
  end
  class << self
    ## Takes an object that has a body and replaces the inline asset
    ## tags it contains with rendered partials.
    def render obj, options={}
      options[:locals] ||= {}
      options[:template] ||= "shared/assets/news/_inline"
      parser = Parser.new obj
      parser.map do |placeholder, doc|
        asset_id = placeholder.attribute('data-asset-id').value
        align    = (data_align = placeholder.attribute('data-align')) ? data_align.value : nil
        uri = URI("http://a.scpr.org/api/assets/#{asset_id}?auth_token=#{Rails.application.secrets.assethost['read_only_token']}")
        response = Net::HTTP.get_response(uri)
        if response.code == "200" && asset_data = (JSON.parse response.body rescue nil)
          view = ActionView::Base.new('app/views', {})
          view.render file: options[:template], locals: options[:locals].merge({content: obj, article: AssetData.new(asset_data), align: align, inline: true})
        end
      end.to_s.html_safe
    end
  end
end
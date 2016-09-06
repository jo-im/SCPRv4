module Filter
  class InlineAssetsFilter < HTML::Pipeline::Filter
    def call
      insert_inline_assets
      doc
    end
  private
    def insert_inline_assets
      context ||= {}
      return if !context[:content]
      cssPath = "img.inline-asset[data-asset-id]"
      context[:options] ||= {}
      context = context[:options][:context] || "news"
      display = context[:options][:display] || "inline"
      doc.css(cssPath).each do |placeholder|
        asset_id = placeholder.attribute('data-asset-id').value
        asset = context[:content].assets.find_by(asset_id:asset_id)
        if asset
          rendered_asset = render_asset content, context: context, display: display, asset:asset
          placeholder.replace Nokogiri::HTML::DocumentFragment.parse(rendered_asset)
        else
          placeholder.remove
        end
      end
    end
    class Simple < HTML::Pipeline::Filter
      # This just uses the existing IMG tag
      # and does not use a template.
      def call
        insert_inline_assets
        doc
      end
    private
      def insert_inline_assets
        context ||= {}
        return if !context[:content]
        doc.css('img.inline-asset[data-asset-id]').each do |element|
          asset = context[:content].assets.find_by asset_id: element['data-asset-id']
          if asset
            element['src'] = asset.full.url
            element['alt'] = asset.caption
          else
            element.remove
          end
        end
      end
    end
  end
end
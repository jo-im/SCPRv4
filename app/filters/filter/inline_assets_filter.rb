module Filter
  class InlineAssetsFilter < HTML::Pipeline::Filter
    # This just uses the existing IMG tag
    # and does not use a template.
    def call
      insert_inline_assets context
      doc
    end
  private
    def insert_inline_assets context={}
      context ||= {}
      doc.css('img.inline-asset[data-asset-id]').each do |element|
        return element.remove if !context[:content]
        asset = context[:content].assets.find_by asset_id: element['data-asset-id']
        if asset
          element['src'] = asset.full.url
          element['alt'] = asset.caption
          # In case a later process needs this information
          # but has no access to the asset object.
          element['data-width']  = asset.full.width
          element['data-height'] = asset.full.height
        else
          element.remove
        end
      end
    end
  end
end
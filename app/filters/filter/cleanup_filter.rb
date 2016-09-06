module Filter
  class CleanupFilter < HTML::Pipeline::Filter
    def call
      strip_comments
      remove_empty_paragraphs
      unwrap_embed_placeholders
      doc
    end
  private
    def unwrap_embed_placeholders
      # Embed placeholders are often wrapped in paragraph tags, which
      # is confusing because the end result is not a block element, and
      # because the paragraph is processed first, it assumes that all
      # its contents are span elements and therefore turns the contents
      # into markdown, which we don't want to have happen in this case.
      # Better just to remove the paragraphs beforehand.
      doc.search("a.embed-placeholder").each do |element|
        parent = element.parent
        if parent && parent.name == "p"
          parent.replace element
        end
      end
    end
    def strip_comments
      doc.xpath('//comment()').remove
    end
    def remove_empty_paragraphs
      doc.search("p").each do |tag|
        contents = tag.content
        if tag.content.strip.empty? || tag.content.strip == "&nbsp;"
          tag.remove
        end
      end
    end
  end
end
require 'reverse_markdown'
require 'htmlentities'
require 'digest'
module AppleNews
  # A collection of methods that are useful to the Apple News publishing callback.
  def elements_to_components html
    processed_html = preprocess(html) # Mostly insert inline assets
    components = Nokogiri::HTML::DocumentFragment.parse(processed_html).children.to_a.map do |element|
      element_to_component element
    end.flatten # we expect components to always come in as arrays, as some of them
                # realistically require two elements(e.g. a figure needs a separate caption element)      
    insert_advertisement components
  end

  def insert_advertisement components
    # find an appropriate place to put an ad.
    components.each_with_index do |component, index|
      if (index > 2) && component.role == "body"
        components.insert(index, {
          role: "medium_rectangle_advertisement"
        })
      end
    end
    components
  end

  def element_to_component element
    if element.name == 'img'
      img_to_figure_component element
    elsif element.name == 'a'
      anchor_to_component element
    else
      element_to_body_component element
    end
  end

  def anchor_to_component element
    if (element.attributes["class"].try(:value).try(:include?, "embed-placeholder") &&
      element.attributes['data-service'].try(:value) &&
      element.attributes['href'])
      embed_placeholder_to_component element
    else
      element_to_body_component element
    end
  end

  def embed_placeholder_to_component element
    url     = element.attributes['href'].try(:value)
    role    = element.attributes['data-service'].try(:value)
    if url  && role && %w(twitter instagram youtube facebook).include?(role) # limit it to compatible providers
      if role == "twitter"
        role = "tweet"
        id_matcher = /^(?<url>https?:\/\/twitter\.com\/(?<username>[-a-zA-Z0-9+&@#%?=~_|!:,.;]+)\/status(es){0,1}\/(?<tweetId>\d+)\/{0,1})/i
        url = url.match(id_matcher)[:url]
        if !url
          element_to_body_component element
        end
      elsif role == 'youtube'
        role = "embedwebvideo"
      elsif role == 'facebook'
        role = 'facebook_post'
      end
      [{
        role: role,
        :"URL" => url
      }]
    else
      element_to_body_component element
    end
  end

  def img_to_figure_component element
    [
      {
        role: "figure",
        :"URL" => element['src'],
        caption: (element['alt'] || element['title'])
      },
      {
        role: "caption",
        text: (element['alt'] || element['title']),
        textStyle: "figcaptionStyle",
      }   
    ]
  end

  def element_to_body_component element
    markup   = element.to_s
    markdown = html_to_markdown(markup)
    output = []
    unless markdown.blank?
      output << {
        role: "body",
        text: markdown,
        layout: "bodyLayout",
        textStyle: "bodyStyle",
        format: "markdown"
      }
    end
    output
  end

  def html_to_markdown html
    HTMLEntities.new.decode ReverseMarkdown.convert html, unknown_tags: :drop
  end

  def preprocess html
    unwrap_embed_placeholders insert_inline_assets html
  end

  def unwrap_embed_placeholders html
    # Embed placeholders are often wrapped in paragraph tags, which
    # is confusing because the end result is not a block element, and
    # because the paragraph is processed first, it assumes that all
    # its contents are span elements and therefore turns the contents
    # into markdown, which we don't want to have happen in this case.
    # Better just to remove the paragraphs beforehand.
    process_markup html, "a.embed-placeholder" do |element|
      parent = element.parent
      if parent && parent.name == "p"
        parent.replace element
      end
    end
  end

  def insert_inline_assets html
    process_markup html, 'img.inline-asset[data-asset-id]' do |element|
      asset = assets.find_by asset_id: element['data-asset-id']
      if asset && asset.owner.try(:include?, "KPCC")
        element['src'] = asset.full.url
        element['alt'] = asset.caption
      else
        element.remove
      end
    end
  end

  def process_markup html, selector, &block
    doc = Nokogiri::HTML(html.force_encoding('ASCII-8BIT'))
    doc.css(selector).each{|element|
      yield element
    }
    doc.css('body').children.to_s.html_safe
  end
end
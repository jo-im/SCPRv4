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
    output = components.dup
    components.each_with_index do |component, index|
      if (index > 2) && component[:role] == "body"
        output.insert(index, {
          role: "medium_rectangle_advertisement"
        })
        return output
      end
    end
    output
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

  class Publisher
    # Used for interacting with the Apple News API
    # and should be called during background job.
    def initialize record
      @record = record
    end
    def perform action
      record = @record
      action = action.to_s
      if action == "upsert"
        unless record.apple_news_article
          insert record
        else
          update record
        end
      elsif action == "delete"
        delete record
      end        
    end
    private
    def find uuid
      client.get_article uuid
    end
    def get record
      if record.apple_news_article
        find record.apple_news_article.uuid
      end
    end
    def insert record
      open_bundle_for record do |file, dir, record|
        response = client.publish_article({'channel_id' => channel_id, file_name: "article.json"}, dir)
        if response.code == 201
          data = JSON.parse(response.to_s)["data"]
          record.apple_news_article = AppleNewsArticle.create uuid: data["id"], revision: data["revision"]
        end
        response
      end
    end
    def update record
      article = record.apple_news_article
      if article.uuid
        open_bundle_for record do |file, dir, record|
          response = client.update_article(article.uuid, article.revision, {'channel_id' => channel_id, file_name: "article.json", "article_dir" => dir})
          if response.code == 200
            data = JSON.parse(response.to_s)["data"]
            article.update revision: data["revision"]
          end
          response
        end
      else
        nil
      end
    end
    def delete record
      article = record.apple_news_article
      uuid = article.try(:uuid)
      if uuid
        response = client.delete_article uuid
        if response.code == 204
          article.destroy
        end
        response
      else
        nil
      end
    end
    def client
      PapiClient::API.new(
        endpoint: Rails.application.secrets.api["apple_news"]["endpoint"], 
        key: Rails.application.secrets.api["apple_news"]["key_id"], 
        secret: Rails.application.secrets.api["apple_news"]["secret"]
      )
    end
    def channel_id
      Rails.application.secrets.api["apple_news"]["channels"]["kpcc"]["id"]
    end
    def open_json_file_for record, &block
      Tempfile.open ['article', '.json'] do |f|
        f.write record.to_apple.to_json
        f.rewind
        path      = Pathname.new(f.path)
        return yield f, path, record
      end
    end

    def download_from_to url, dest
      open(dest, 'wb') do |file|
        begin  
          file << open(url).read
        rescue SocketError
          return false
        end
      end        
      true
    end

    def open_bundle_for record, &block
      # This opens a temporary directory for our "bundle",
      # which is where we will include all the files required
      # to publish our article, the most important one being
      # article.json.
      dir = Dir.mktmpdir
      doc = record.to_apple
      # thumb_url  = record.try(:asset).try(:small).try(:url)
      # if thumb_url
      # # The thumbnail, unlike images in the article itself,
      # # must be a part of the bundle, so we have to download
      # # it and include it as a file with a specific name.
      #   if download_from_to(thumb_url, "#{dir}/thumbnail.jpg")
      #     doc[:metadata][:thumbnailURL] = "bundle://thumbnail.jpg"
      #   end
      # end
      File.open("#{dir}/article.json", "w") do |f|
        f.write doc.to_json
        f.rewind
        return yield f, dir, record
      end
      Dir.delete dir
    end
  end

end
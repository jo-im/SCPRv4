xml.instruct!(:xml, version: "1.0", encoding: "UTF-8")
xml.urlset xmlns: "http://www.sitemaps.org/schemas/sitemap/0.9", "xmlns:news" => "http://www.google.com/schemas/sitemap-news/0.9" do
  @content.each do |object|
    xml.url do
      xml.loc         object.public_url
      xml.changefreq  @changefreq || "daily"
      xml.priority    @priority || "0.5"

      if object.respond_to? :published_at
        xml.lastmod   object.published_at.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")
      end

      xml.tag! 'news:news' do

        xml.tag! 'news:publication' do
          xml.tag! 'news:name', '89.3 KPCC'
          xml.tag! 'news:language', 'en'
        end

        if @genres
          xml.tag! 'news:genres', @genres
        end

        xml.tag! 'news:publication_date', object.published_at.utc.strftime("%Y-%m-%dT%H:%M:%S+00:00")

        xml.tag! 'news:title', object.try(:headline) || object.try(:title)

        if object.respond_to?(:tags) && object.tags.length > 0
          xml.tag! 'news:keywords', [object.category].concat(object.tags).compact.map{|t| t.try(:title).try(:downcase)}.join(', ')
        end

      end

    end
  end
end

class ProgramOverviewCell < Cell::ViewModel
  include Orderable
  include ActionView::Helpers::TagHelper

  property :title

  def show
    render.html_safe
  end

  def teaser
    model.teaser.try(:html_safe)
  end

  def description
    model.description.try(:html_safe)
  end

  def airtime
    if model.airtime.present?
      content_tag :span, class: "o-content-cluster__datetime" do
        "Airs #{model.airtime}".html_safe
      end
    end
  end

  def web_link
    if link = model.get_link("website")
      content_tag :li, class: "site" do
        link_to "Website", link,
          :class  => "o-content-cluster__share-link o-content-cluster__share-link--archive"
      end
    end
  end

  def facebook_link
    if link = model.get_link("facebook")
      content_tag :li, class: "facebook" do
        link_to link, :class  => "o-content-cluster__share-link o-content-cluster__share-link--facebook", :target => :_blank do
          image_tag("o-content-cluster/fb.svg") + "Facebook"
        end
      end
    end
  end

  def podcast_link
    if link = abstract_program.podcast_url
      content_tag :li, class: "podcast" do
        link_to link, :class  => "o-content-cluster__share-link o-content-cluster__share-link--podcast", :target => :_blank do
          image_tag("o-content-cluster/podcast.svg") + "Podcast"
        end
      end
    end
  end

  def rss_link
    if link = abstract_program.rss_url
      content_tag :li, class: "email" do
        link_to link, :class  => "o-content-cluster__share-link o-content-cluster__share-link--rss", :target => :_blank do
          image_tag("o-content-cluster/rss.svg") + "RSS"
        end
      end
    end
  end

  # def twitter_link
  #   if link = model.get_link("twitter")
  #     content_tag :li, class: "twitter" do
  #       link_to twitter_profile_url(link), :class  => "o-content-cluster__share-link o-content-cluster__share-link--twitter" do
  #         image_tag("o-content-cluster/tw.svg") + "@#{link}"
  #       end
  #     end
  #   end
  # end

  def email_link
    if link = model.get_link("email")
      content_tag :li, class: "email" do
        link_to link, :class  => "o-content-cluster__share-link o-content-cluster__share-link--email" do
          image_tag("o-content-cluster/email.svg") + "Email"
        end
      end
    end
  end

  def abstract_program
    @abstract_program ||= model
  end

end

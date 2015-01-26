class ProgramPresenter < ApplicationPresenter
  presents :program
  delegate :title, :slug, :public_url, :public_path, to: :program


  def teaser
    program.teaser.try(:html_safe)
  end

  def description
    program.description.try(:html_safe)
  end

  def airtime
    if program.airtime.present?
      h.content_tag :h3 do
        "Airs #{program.airtime}".html_safe
      end
    end
  end

  def web_link
    if link = program.get_link("website")
      h.content_tag :li, class: "site" do
        h.link_to "Website", link,
          :class  => "archive with-icon"
      end
    end
  end

  def facebook_link
    if link = program.get_link("facebook")
      h.content_tag :li, class: "facebook" do
        h.link_to "Facebook", link,
          :class  => "facebook with-icon"
      end
    end
  end

  def podcast_link
    if link = abstract_program.podcast_url
      h.content_tag :li, class: "podcast" do
        h.link_to "Podcast", link,
          :class  => "podcast with-icon"
      end
    end
  end

  def rss_link
    if link = abstract_program.rss_url
      h.content_tag :li, class: "rss" do
        h.link_to "RSS", link,
          :class  => "rss with-icon"
      end
    end
  end

  def twitter_link
    if link = program.get_link("twitter")
      h.content_tag :li, class: "twitter" do
        h.link_to "@#{link}",
          h.twitter_profile_url(link),
          :class  => "twitter with-icon"
      end
    end
  end

  def email_link
    if link = program.get_link("email")
      h.content_tag :li, class: "email" do
        h.link_to "Email", link,
          :class  => "email with-icon"
      end
    end
  end

  private

  def abstract_program
    @abstract_program ||= program.to_program
  end
end

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
      link
    end
  end

  def podcast_link
    if link = program.get_link("podcast")
      link
    end
  end

  def rss_link
    if link = program.get_link("rss")
      link
    end
  end

  def twitter_link
    if link = program.get_link("twitter")
      link
    end
  end

  def email_link
    if link = program.get_link("email")
      link
    end
  end

  private

  def abstract_program
    @abstract_program ||= program
  end
end

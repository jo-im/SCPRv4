class BlogHostsCell < Cell::ViewModel
  include Orderable

  property :authors

  def show
    render if authors
  end

  def heading
    if authors.length > 1
      "Your hosts"
    else
      "Your host"
    end
  end

  def twitter_profile_url handle
    "https://twitter.com/#{handle.parameterize}"
  end

  def twitter_link author
    if author.twitter_handle
      content_tag :li, class: "twitter" do
        link_to twitter_profile_url(author.twitter_handle), :class  => "o-content-cluster__share-link o-content-cluster__share-link--twitter" do
          image_tag("o-content-cluster/tw.svg") + "Follow @#{author.twitter_handle}"
        end
      end
    end
  end

  def email_link author
    if author.email
      content_tag :li, class: "email" do
        mail_to author.email, :class  => "o-content-cluster__share-link o-content-cluster__share-link--email" do
          image_tag("o-content-cluster/email.svg") + "Email #{author.name.split(" ").first()}"
        end
      end
    end
  end

  def portfolio_link author
    content_tag :li, class: "site" do
      link_to "All posts by #{author.name.split(" ").first()}", author.public_path,
        :class  => "o-content-cluster__share-link o-content-cluster__share-link--archive"
    end
  end

end

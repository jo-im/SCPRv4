FactoryGirl.define do
  factory :remote_article do
  end

  factory :npr_article, class: "RemoteArticle" do
    source "npr"
    headline "NPR Article"
    teaser "This is a short thing about the article"
    published_at { Time.zone.now }
    url "http://npr.org/wat.html"
    article_id 12345
    is_new true
    news_agency "NPR"
  end

  factory :pmp_article, class: "RemoteArticle" do
    source "pmp"
    headline "PMP Article"
    teaser "This is a short thing about the article"
    published_at { Time.zone.now }
    url "http://marketplace.org/wat.html"
    article_id "fe111285-92c5-f5de-7b34-8a720d5fc750"
    is_new true
    news_agency "Marketplace"
  end

end

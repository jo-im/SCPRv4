FactoryGirl.define do
  factory :remote_article do
  end

  factory :chr_article, class: "RemoteArticle" do
    source "chr"
    headline "CHR Article"
    teaser "This is a short thing about the article"
    published_at { Time.now }
    url "http://chr.org/wat.html"
    article_id 12345
    is_new true
  end

  factory :npr_article, class: "RemoteArticle" do
    source "npr"
    headline "CHR Article"
    teaser "This is a short thing about the article"
    published_at { Time.now }
    url "http://chr.org/wat.html"
    article_id 12345
    is_new true
  end
end

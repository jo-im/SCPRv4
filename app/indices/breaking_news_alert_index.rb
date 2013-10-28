ThinkingSphinx::Index.define :breaking_news_alert, with: :active_record do
  indexes headline
  indexes alert_type
  indexes teaser
  has published_at
end

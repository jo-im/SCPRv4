# TODO Add caching at the index level (this file) and make sure it doesn't
# break anything. The benchmarks showed a ~14% performance boost.
json.partial! api_view_path("shared", "meta")

json.cache! ['/api/v3/articles', @query, @classes, @limit, @page, @conditions], expires_in: 5.minutes do
	json.articles do
		json.partial! api_view_path("articles", "collection"), articles: @articles
	end
end

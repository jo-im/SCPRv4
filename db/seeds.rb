# Setup permissions based on Outpost's registered models.
Outpost.config.registered_models.each do |resource|
  Permission.create(resource: resource)
end

AdminUser.create name: "scprdev", username: "scprdev", password: "password", email: "scprdev@scpr.org", is_superuser: true, can_login: true

[
  "Local",
  "US & World",
  "Politics",
  "Science",
  "Arts & Entertainment",
  "Business",
  "Crime & Justice",
  "Education",
  "Health"
].each do |title|
  Category.create title: title, slug: title.parameterize[0...50].sub(/-+\z/, "")
end
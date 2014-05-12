class MigrateCategories < ActiveRecord::Migration
  def up
    # TODO: Redirect all old arts categories to "/arts" (including feed)
    # TODO Put a model stub for this in place
    # TODO: Redirect /money to /business
    # TODO: Redirect "/california" to "/local" (including feed)

    add_column :contentbase_category, :short_title, :string

    Category.all.each do |category|
      category.update_column(:short_title, category.title)
    end

    category_classes = [
      Abstract,
      ContentShell,
      BlogEntry,
      Event,
      NewsStory,
      Podcast,
      ShowSegment,
      Vertical
    ]


    # Update titles
    politics = Category.find_by_slug!("politics")
    politics.update_columns(title: "Politics", short_title: "Politics")

    business = Category.find_by_slug!("money")
    business.update_columns(title: "Business & Economy", short_title: "Business", slug: "business")

    crime = Category.find_by_slug!("crime")
    crime.update_columns(title: "Crime & Justice", short_title: "Crime & Justice")

    environment = Category.find_by_slug!("environment")
    environment.update_columns(title: "Environment & Science", short_title: "Science")

    local = Category.find_by_slug!("local")
    local.update_columns(title: "Local", short_title: "Local")

    world = Category.find_by_slug!("world")
    world.update_columns(title: "US & World", short_title: "US & World")

    arts = Category.find_by_slug!("arts")
    arts.update_columns(title: "Arts & Entertainment", short_title: "Arts & Entertainment")

    # Create new category
    community = Category.create!(
      :title          => "Emerging Communities",
      :short_title    => "Immigrations & Emerging Communities",
      :slug           => "immigration")


    # Migrate Emerging Communities categories
    BlogEntry.where(blog_id: 22, category_id: nil).update_all(category_id: community.id)


    # Migrate Arts categories
    arts_categories = Category.where(slug: ["film", "culture", "music", "food", "books"])

    category_classes.each do |klass|
      klass.where(category_id: arts_categories.map(&:id)).update_all(category_id: arts.id)
    end

    arts_categories.destroy_all


    # Migrate California categories
    california = Category.find_by_slug!('california')

    category_classes.each do |klass|
      klass.where(category_id: california.id).update_all(category_id: local.id)
    end

    california.destroy
  end

  def down
    # nope
  end
end

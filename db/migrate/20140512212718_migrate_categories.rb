class MigrateCategories < ActiveRecord::Migration
  def up
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
    politics.update_columns(title: "Politics")

    business = Category.find_by_slug!("money")
    business.update_columns(title: "Business & Economy", slug: "business")

    crime = Category.find_by_slug!("crime")
    crime.update_columns(title: "Crime & Justice")

    environment = Category.find_by_slug!("environment")
    environment.update_columns(title: "Environment & Science")

    local = Category.find_by_slug!("local")
    local.update_columns(title: "Local")

    world = Category.find_by_slug!("world")
    world.update_columns(title: "US & World")

    arts = Category.find_by_slug!("arts")
    arts.update_columns(title: "Arts & Entertainment")

    # Create new category
    community = Category.create!(
      :title          => "Immigrations & Emerging Communities",
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

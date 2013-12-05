class MigrateAssetSchemeToAssetIds < ActiveRecord::Migration
  def up
    NewsStory.find_each do |story|
      if %w[wide float].include?(story.story_asset_scheme) ||
      story.story_asset_scheme.blank?
        story.asset_display = :photo

      elsif story.story_asset_scheme == "hidden"
        story.asset_display = :hidden

      elsif story.story_asset_scheme == "slideshow"
        story.asset_display = :slideshow

      elsif story.story_asset_scheme == "video"
        if story.extra_asset_scheme == "sidebar"
          puts ">>> VIDEO + EXTRA ASSETS FOUND. Ignoring. #{story.simple_title}"
        else
          story.asset_display = :video
        end
      end
    end


    BlogEntry.find_each do |story|
      if %w[wide float].include?(story.blog_asset_scheme) ||
      story.blog_asset_scheme.blank?
        story.asset_display = :photo

      elsif story.blog_asset_scheme == "hidden"
        story.asset_display = :hidden

      elsif story.blog_asset_scheme == "slideshow"
        story.asset_display = :slideshow

      elsif story.blog_asset_scheme == "video"
        story.asset_display = :video
      end
    end


    ShowSegment.find_each do |story|
      if %w[wide float].include?(story.segment_asset_scheme) ||
      story.segment_asset_scheme.blank?
        story.asset_display = :photo

      elsif story.segment_asset_scheme == "hidden"
        story.asset_display = :hidden

      elsif story.segment_asset_scheme == "slideshow"
        story.asset_display = :slideshow

      elsif story.segment_asset_scheme == "video"
        story.asset_display = :video
      end
    end


    Event.find_each do |story|
      if %w[wide float].include?(story.event_asset_scheme) ||
      story.event_asset_scheme.blank?
        story.asset_display = :photo

      elsif story.event_asset_scheme == "hidden"
        story.asset_display = :hidden

      elsif story.event_asset_scheme == "slideshow"
        story.asset_display = :slideshow

      elsif story.event_asset_scheme == "video"
        story.asset_display = :video
      end
    end

  end

  def down
    NewsStory.update_all(asset_display_id: nil)
    Event.update_all(asset_display_id: nil)
    BlogEntry.update_all(asset_display_id: nil)
    ShowSegment.update_all(asset_display_id: nil)
  end
end

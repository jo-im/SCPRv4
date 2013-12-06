class MigrateAssetSchemeToAssetIds < ActiveRecord::Migration
  def up
    NewsStory.find_each do |story|
      if %w[wide float].include?(story.story_asset_scheme) ||
      story.story_asset_scheme.blank?
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:photo])

      elsif story.story_asset_scheme == "hidden"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:hidden])

      elsif story.story_asset_scheme == "slideshow"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:slideshow])

      elsif story.story_asset_scheme == "video"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:video])

        if story.extra_asset_scheme == "sidebar"
          puts ">>> VIDEO + EXTRA ASSETS FOUND. #{story.simple_title}"
        end
      end
    end


    BlogEntry.find_each do |story|
      if %w[wide float].include?(story.blog_asset_scheme) ||
      story.blog_asset_scheme.blank?
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:photo])

      elsif story.blog_asset_scheme == "hidden"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:hidden])

      elsif story.blog_asset_scheme == "slideshow"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:slideshow])

      elsif story.blog_asset_scheme == "video"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:video])
      end
    end


    ShowSegment.find_each do |story|
      if %w[wide float].include?(story.segment_asset_scheme) ||
      story.segment_asset_scheme.blank?
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:photo])

      elsif story.segment_asset_scheme == "hidden"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:hidden])

      elsif story.segment_asset_scheme == "slideshow"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:slideshow])

      elsif story.segment_asset_scheme == "video"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:video])
      end
    end


    Event.find_each do |story|
      if %w[wide float].include?(story.event_asset_scheme) ||
      story.event_asset_scheme.blank?
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:photo])

      elsif story.event_asset_scheme == "hidden"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:hidden])

      elsif story.event_asset_scheme == "slideshow"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:slideshow])

      elsif story.event_asset_scheme == "video"
        story.update_column(:asset_display_id, ContentBase::ASSET_DISPLAY_IDS[:video])
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

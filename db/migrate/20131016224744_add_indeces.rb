class AddIndeces < ActiveRecord::Migration
  def up
    add_index :abstracts, :updated_at
    add_index :abstracts, :article_published_at

    add_index :auth_user, :name
    add_index :auth_user, :is_superuser
    add_index :auth_user, :can_login

    add_index :bios_bio, :name

    add_index :blogs_blog, :is_active

    add_index :blogs_entry, :updated_at
    add_index :blogs_entry, :published_at
    add_index :blogs_entry, :status

    add_index :contentbase_category, :title
    add_index :contentbase_category, :is_news

    add_index :contentbase_contentalarm, :fire_at

    add_index :contentbase_contentshell, :updated_at
    add_index :contentbase_contentshell, :published_at
    add_index :contentbase_contentshell, :status

    add_index :contentbase_featuredcomment, :created_at

    add_index :contentbase_featuredcommentbucket, :title
    add_index :contentbase_featuredcommentbucket, :created_at
    add_index :contentbase_featuredcommentbucket, :updated_at

    add_index :contentbase_misseditbucket, :title

    add_index :data_points, :updated_at

    add_index :editions, :published_at
    add_index :editions, :updated_at
    add_index :editions, :status

    add_index :events, :starts_at
    add_index :events, :is_kpcc_event

    add_index :flatpages_flatpage, :updated_at

    add_index :layout_breakingnewsalert, :published_at
    add_index :layout_breakingnewsalert, :alert_type
    add_index :layout_breakingnewsalert, :email_sent
    add_index :layout_breakingnewsalert, :mobile_notification_sent

    add_index :layout_homepage, :updated_at
    add_index :layout_homepage, :published_at

    add_index :news_story, :updated_at
    add_index :news_story, :status

    add_index :podcasts, :title
    add_index :podcasts, :is_listed

    add_index :press_releases, :created_at

    add_index :programs_kpccprogram, :title

    add_index :remote_articles, :published_at
    add_index :remote_articles, :source

    add_index :schedule_occurrences, :updated_at
    add_index :schedule_occurrences, :starts_at

    add_index :shows_episode, :air_date
    add_index :shows_episode, :published_at
    add_index :shows_episode, :status

    add_index :shows_segment, :updated_at
    add_index :shows_segment, :published_at
    add_index :shows_segment, :status

    add_index :versions, :created_at
  end

  def down
    remove_index :abstracts, :updated_at
    remove_index :abstracts, :article_published_at
    remove_index :auth_user, :name
    remove_index :auth_user, :is_superuser
    remove_index :auth_user, :can_login
    remove_index :bios_bio, :name
    remove_index :blogs_blog, :is_active
    remove_index :blogs_entry, :updated_at
    remove_index :blogs_entry, :published_at
    remove_index :blogs_entry, :status
    remove_index :contentbase_category, :title
    remove_index :contentbase_category, :is_news
    remove_index :contentbase_contentalarm, :fire_at
    remove_index :contentbase_contentshell, :updated_at
    remove_index :contentbase_contentshell, :published_at
    remove_index :contentbase_contentshell, :status
    remove_index :contentbase_featuredcomment, :created_at
    remove_index :contentbase_featuredcommentbucket, :title
    remove_index :contentbase_featuredcommentbucket, :created_at
    remove_index :contentbase_featuredcommentbucket, :updated_at
    remove_index :contentbase_misseditbucket, :title
    remove_index :data_points, :updated_at
    remove_index :editions, :published_at
    remove_index :editions, :updated_at
    remove_index :editions, :status
    remove_index :events, :starts_at
    remove_index :events, :is_kpcc_event
    remove_index :flatpages, :updated_at
    remove_index :layout_breakingnewsalert, :published_at
    remove_index :layout_breakingnewsalert, :alert_type
    remove_index :layout_breakingnewsalert, :email_sent
    remove_index :layout_breakingnewsalert, :mobile_notification_sent
    remove_index :layout_homepage, :updated_at
    remove_index :layout_homepage, :published_at
    remove_index :news_story, :updated_at
    remove_index :news_story, :status
    remove_index :podcasts, :title
    remove_index :podcasts, :is_listed
    remove_index :press_release, :created_at
    remove_index :programs_kpccprogram, :title
    remove_index :remote_articles, :published_at
    remove_index :remote_articles, :source
    remove_index :schedule_occurrences, :updated_at
    remove_index :schedule_occurrences, :starts_at
    remove_index :shows_episode, :air_date
    remove_index :shows_episode, :published_at
    remove_index :shows_episode, :status
    remove_index :shows_segment, :updated_at
    remove_index :shows_segment, :published_at
    remove_index :shows_segment, :status
    remove_index :versions, :created_at
  end
end

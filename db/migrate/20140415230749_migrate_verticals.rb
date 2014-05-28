class MigrateVerticals < ActiveRecord::Migration
  def change
    Category.where(is_active: true).each do |category|
      vertical = Vertical.create({
        :category_id => category.id,
        :title       => category.title,
        :slug        => category.slug,
        :description => category.description,
        :featured_interactive_style_id => category.featured_interactive_style_id,
        :blog_id => category.blog_id
      })

      if quote = Quote.where(category_id: category.id).order('created_at desc').first
        vertical.quote = quote
      end

      VerticalIssue.where(category_id: category.id).each do |issue|
        issue.vertical = vertical
        issue.save!
      end

      VerticalReporter.where(category_id: category.id).each do |reporter|
        reporter.vertical = vertical
        reporter.save!
      end

      VerticalArticle.where(category_id: category.id).each do |article|
        article.vertical = vertical
        article.save!
      end

      vertical.save!
    end

    vp = Permission.create(resource: "Vertical")
    cp = Permission.find_by_resource("Category")

    cp.user_permissions.each do |up|
      UserPermission.create(admin_user_id: up.admin_user_id, permission_id: vp.id)
    end
  end
end

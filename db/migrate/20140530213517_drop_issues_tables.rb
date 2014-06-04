class DropIssuesTables < ActiveRecord::Migration
  def change
    drop_table :issues
    drop_table :article_issues
    drop_table :category_issues

    p = Permission.where(resource: "Issue").first
    UserPermission.where(permission_id: p.id).destroy_all
    p.delete
  end
end

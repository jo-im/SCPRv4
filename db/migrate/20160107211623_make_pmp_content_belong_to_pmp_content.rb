class MakePmpContentBelongToPmpContent < ActiveRecord::Migration
  def change
    add_reference :pmp_contents, :pmp_content
    add_column    :pmp_contents, :profile, :string
  end
end

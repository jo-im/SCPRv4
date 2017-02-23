class MigrateTheFrameFormText < ActiveRecord::Migration
  def up
    KpccProgram.where(slug: "the-frame").first.update({
      newsletter_form_heading: "LIKE THE FRAME?",
      newsletter_form_caption: "Catch up each afternoon with The Frame newsletter."
    })
  end
  def down
    KpccProgram.where(slug: "the-frame").first.update({
      newsletter_form_heading: nil,
      newsletter_form_caption: nil
    })
  end
end

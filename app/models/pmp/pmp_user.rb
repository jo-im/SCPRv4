class PmpUser < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'user'")}
  belongs_to :pmp_group, class_name: :PmpGroup, foreign_key: :pmp_content_id

  def publish
    # don't publish this
    false
  end

  def set_profile
    self.profile ||= "user"
  end

  def to_pmp_link
    PMP::Link.new({title: title, href: "http://www.scpr.org/terms/"})
  end

  def permissions
    []
  end

end
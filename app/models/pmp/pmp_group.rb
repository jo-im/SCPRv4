class PmpGroup < PmpContent
  self.table_name = "pmp_contents"
  default_scope ->{where("pmp_contents.profile = 'group'")}
  has_many :pmp_links, dependent: :destroy, foreign_key: :pmp_content_id
  has_many :pmp_users, foreign_key: :pmp_content_id
  validates :title, presence: true

  def publish
    doc = pmp('write').doc_of_type("group")
    doc.title = title
    doc.links ||= {}
    doc.links['enclosure'] = pmp_users.map(&:link)
    if url = doc.save
      update! guid: doc.guid
    end
  end

  def set_profile
    self.profile ||= "group"
  end

  def link
    l = super
    l.operation = "read"
    l
  end

  def permissions
    []
  end

end
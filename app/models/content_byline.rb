class ContentByline < ActiveRecord::Base
  self.table_name =  "contentbase_contentbyline"

  ROLE_EXTRA        = -1
  ROLE_PRIMARY      = 0
  ROLE_SECONDARY    = 1
  ROLE_CONTRIBUTING = 2

  ROLE_TEXT = {
      ROLE_PRIMARY      => "Primary",
      ROLE_SECONDARY    => "Secondary",
      ROLE_CONTRIBUTING => "Contributing",
      ROLE_EXTRA        => "Extra"
  }

  ROLE_MAP = {
    :primary      => ROLE_PRIMARY,
    :secondary    => ROLE_SECONDARY,
    :contributing => ROLE_CONTRIBUTING,
    :extra        => ROLE_EXTRA
  }

  ROLES = ROLE_TEXT.map { |k,v| [v, k] }[0..2] # TODO this is terrible

  belongs_to :content, polymorphic: true, touch:true
  belongs_to :user, class_name: "Bio"

  self.versioned_attributes = ["name", "role", "user_id"]

  #-----------------------

  class << self
    #-----------------------
    # Takes a hash of bylines and concatenates them intelligently
    # It is assumed that the strings passed-in will be:
    def digest(elements)
      primary   = elements[:primary]
      secondary = elements[:secondary]
      extra     = elements[:extra]

      names = [primary, secondary].reject { |e| e.blank? }.join(" with ")
      # Sometimes the primary byline of a story might be the same as its 
      # secondary or extra(as with remote articles), so we call #uniq on
      # the array of names to prevent duplication.
      [names, extra].reject { |e| e.blank? }.uniq.join(" | ")
    end
  end

  #-----------------------

  def role_text
    ROLE_TEXT[self.role]
  end

  #-----------------------

  def display_name
    @display_name ||= (self.user.try(:name) || self.name)
  end
end

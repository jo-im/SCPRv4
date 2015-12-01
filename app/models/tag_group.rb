class TagGroup
  attr_accessor :name
  def initialize name
    @name = name
  end
  def tags
    Tag.where(tag_type: @name)
  end
  class << self
    def all
      Tag.select(:tag_type).group(:tag_type).pluck(:tag_type).map{|t| self.new(t)}
    end
  end
end
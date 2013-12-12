module TestClass
  class PublishableEntity
    include StatusBuilder

    has_status

    status :draft do |s|
      s.id = 0
      s.text = "Draft"
      s.unpublished!
    end

    status :pending do |s|
      s.id = 1
      s.text = "Pending"
      s.pending!
    end

    status :published do |s|
      s.id = 2
      s.text = "Published"
      s.published!
    end
  end
end

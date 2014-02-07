module FactoryAttributesBuilder
  def build_attributes(*args)
    build(*args).attributes.except("id", "created_at", "updated_at")
  end
end

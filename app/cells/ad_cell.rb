class AdCell < Cell::ViewModel
  include Orderable
  cache :show do
    ["c-ad", model[:id], ad_key, model[:class], model[:order]]
  end

  def show &block
    (render + (block_given? ? yield : "")).html_safe
  end

  def ad_key
    "slot_#{model[:slot]}"
  end

  def attribution?
    # By default, attribution is turned on.
    !model.has_key?(:attribution) || model[:attribution]
  end

  def order
    "style=\"order: #{model[:order]};\""
  end

  def id
    model[:id]
  end

end

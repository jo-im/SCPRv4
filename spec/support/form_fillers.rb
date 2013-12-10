##
# Form Fillers
#
# Fill in forms with the attributes from a given record
# Also acts as capybara field abstraction
#
module FormFillers
  # Fill all fields, regardless of its validation
  def fill_all_fields(record, options={})
    record.attributes.keys.each do |attribute|
      fill_field(record, attribute, options)
    end
  end

  #------------------
  # Fill only required fields
  def fill_required_fields(record, options={})
    record.class.validators.select { |v|
      v.is_a? ActiveModel::Validations::PresenceValidator
    }.each do |validator|
      validator.attributes.each do |attribute|
        fill_field(record, attribute, options)
      end
    end
  end

  #------------

  private

  def fill_field(record, attribute, options={})
    if record.class.reflect_on_association(attribute)
      if record.respond_to?("#{attribute}_json=")
        # We're using an aggregator
        attribute = :"#{attribute}_json"
        # This assumes that the HTML ID of the field is the same
        # as the attribute name. It won't be, necessarily.
        fill_field(record, attribute, attribute => attribute)
        return
      else
        attribute = "#{attribute}_id"
      end
    end

    field_id = options[attribute] ||
      "#{record.class.singular_route_key}_#{attribute}"

    value = record.send(attribute)

    # For serialized arrays acting as has_many associations
    if record.class
    .serialized_attributes[attribute.to_s].try(:object_class) == Array
      record.send(attribute).each do |v|
        field = first(field_id + "_#{v}")
        interact(field, value)
      end
    else
      if field = find_by_id(field_id)
        interact(field, value)
      end
    end
  end

  #----------------

  def interact(field, value)
    # If the field is disabled, leave it alone.
    return if field[:disabled]

    case field.tag_name
    when "select"
      field = find("##{field[:id]} option[value='#{value}']")
      field.select_option

    when "textarea"
      field.set(value)

    when "input"
      case field[:type]
      when "checkbox"
        field.click
      when "hidden"
        field.set(value)
      else
        field.set(value)
      end

    else
      raise StandardError, "Unexpected field tag_name: #{field.tag_name}"
    end
  end
end

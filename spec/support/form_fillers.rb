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
      attribute = "#{attribute}_id"
    end

    field_id  = options[attribute] ||
      "#{record.class.singular_route_key}_#{attribute}"

    value = record.send(attribute)

    # For serialized arrays acting as has_many associations
    if record.class
    .serialized_attributes[attribute.to_s].try(:object_class) == Array
      record.send(attribute).each do |v|
        interact(field_id + "_#{v}", value)
      end
    else
      if page.has_field? field_id
        interact(field_id, value)
      end
    end
  end

  #----------------

  def interact(field_id, value)
    field = find_field(field_id)

    case field.tag_name
    when "select"
      text = find("##{field_id} option[value='#{value}']").text
      select text, from: field_id

    when "textarea"
      fill_in field_id, with: value

    when "input"
      case field[:type]
      when "checkbox"
        check(field_id)

      else
        fill_in field_id, with: value
      end

    else
      raise StandardError, "Unexpected field tag_name: #{field.tag_name}"
    end
  end
end

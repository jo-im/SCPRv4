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
        fill_field(record, attribute, attribute => attribute.to_s)
        return
      else
        attribute = "#{attribute}_id"
      end
    end

    field_id = options[attribute] ||
      "#{record.class.singular_route_key}_#{attribute}"

    value = record.send(attribute)

    begin
      field = find_by_id(field_id)
      interact(field, value)
    rescue Capybara::ElementNotFound => e
      if value.is_a?(Array)
        begin
          value.each do |v|
            field = find_by_id(field_id + "_#{v}")
            interact(field, v)
          end
        rescue Capybara::ElementNotFound
          # raise our original failure?
          raise e
        end
      else
        raise e
      end
    end

  end

  #----------------

  def interact(field, value)
    # If the field is disabled, leave it alone.
    return if field[:disabled]

    case field.tag_name
    when "select"
      # For select tags, we want to assert that the value we're
      # trying to select is actually an option in the drop-down.
      # Wrap it in an array to support multi-selects
      Array(value).each do |opt|
        field = find("##{field[:id]} option[value='#{opt}']")
        field.select_option
      end

    else
      field.set(value)
    end
  end
end

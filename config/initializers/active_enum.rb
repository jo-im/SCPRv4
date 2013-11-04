# Form helper integration
# require 'active_enum/form_helpers/formtastic'  # for Formtastic <2
# require 'active_enum/form_helpers/formtastic2' # for Formtastic 2.x
require 'active_enum/form_helpers/simple_form'
ActiveEnum.setup do |config|

  # Extend classes to add enumerate method
  # config.extend_classes = [ ActiveRecord::Base ]

  # Return name string as value for attribute method
  config.use_name_as_value = false

  # Storage of values (:memory, :i18n)
  # config.storage = :memory

end

ActiveEnum.define do
  enum(:feature_type) do
    value id: 1, name: 'Slideshow'
    value id: 2, name: 'Video'
    value id: 3, name: 'Poll'
    value id: 4, name: 'Map'
    value id: 5, name: 'Audio'
    value id: 6, name: 'Infographic'
  end

end

module Concern
  module Sanitizers
    module UrlSanitizer
      ## TO USE:
      ## before_save ->{ sanitize_urls :url }
      extend ActiveSupport::Concern
      def sanitize_urls *attr_names
        attr_names.each do |attr_name|
          send("#{attr_name}=", send(attr_name).strip) if send(attr_name).respond_to?(:strip)
        end
      end
    end 
  end 
end

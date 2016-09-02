##
# Google AMP
#
module Concern
  module Controller
    module Amp
      extend ActiveSupport::Concern

      module ClassMethods
        def amplify *args
          args.each do |name|
            write_amp_method name
          end
        end

        private

        def write_amp_method name
          # What this does it creates a wrapper around the existing
          # controller actions and, if the "amp" query parameter
          # is present in the request, will render with a different template.
          omethod = instance_method(name)
          define_method name do
            if params.has_key?(:amp)
              fc = headless_controller
              omethod.bind(fc).call
              @amp_record = fc.amp_record
              response.headers['Content-Security-Policy'] = "default-src *; script-src *; script-src 'unsafe-eval'; style-src *; style-src 'unsafe-inline'; img-src *"
              render(template: "amp/single", layout: "application.amp.erb") and return
            else
              omethod.bind(self).call
            end
          end
        end
      end

      module InstanceMethods
        # This is used to call the original controller action
        # while overriding render/redirect methods so as to
        # not run into a multiple-render error when we call
        # the AMP render method.

        def headless_controller
          klass = Class.new(self.class) do
            attr_accessor :params, :amp_record, :request, :response
            def initialize request:, response:, params:{}
              method(__method__).parameters.each{|p| instance_variable_set("@#{p[1]}", binding.local_variable_get(p[1]))}
            end
          end
          [:render, :redirect_to, :respond_with].each do |action|
            klass.send(:define_method, action) { |*args| }
          end
          klass.new request: request, response: response, params: params
        end
      end
    end
  end
end

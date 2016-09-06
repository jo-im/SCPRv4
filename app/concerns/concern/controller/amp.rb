##
# Google AMP
#
module Concern
  module Controller
    module Amp
      extend ActiveSupport::Concern

      def amplify *args
        helper_method :pipeline_filter
        args.last.is_a?(Hash) ? (options = args.pop) : (options = {})
        args.each do |name|
          _write_amp_method name, options
        end
      end

      def _amp_options
        @_amp_options ||= {
          template: "amp/default",
          layout: "application.amp.erb",
          content_security_policy: [
            "default-src *", 
            "script-src *", 
            "style-src * 'unsafe-inline'",
            "img-src 'self' data:",
            "font-src *"
          ]
        }
      end

      def _headless request, response, params
        # "Clones" the original controller to create a wrapper
        # that can execute action methods without responding to
        # render methods.
        klass = Class.new(self) do
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

      def _expose exposures, ctrlr
        # This allows us to shoehorn variables and methods
        # from the host controller into locals available 
        # to the AMP view.
        exposed = {}
        exposures.each do |k, v|
          if v.is_a?(Proc)
            exposed[k] = ctrlr.instance_eval{ v.call(ctrlr) }
          elsif v.is_a?(String)
            exposed[k] = ctrlr.instance_eval v
          end
        end
        exposed
      end

      private

      def _write_amp_method name, options
        # What this does is create a wrapper around the existing
        # controller actions and, if the "amp" query parameter
        # is present in the request, will render with a different template.
        omethod = instance_method(name)
        default_render_options = {template: _amp_options[:template], layout: _amp_options[:layout]}
        merged_render_options  = default_render_options.merge(options)
        _add_helpers
        define_method name do
          if params.has_key?(:amp)
            fc = self.class._headless(request, response, params)
            omethod.bind(fc).call # bind original method to headless controller
            if options[:expose]
              merged_render_options[:locals] ||= {}
              self.class._expose(options[:expose], fc).each do |k, v|
                if k.to_s.match(/^@/) # define as instance variable if starts with @
                  instance_variable_set(k, v)
                else # define as a local variable
                  merged_render_options[:locals][k] = v
                end
              end
            end
            response.headers['Content-Security-Policy'] = self.class._amp_options[:content_security_policy].join("; ")
            render(merged_render_options)
          else
            omethod.bind(self).call
          end
        end
      end

      def _add_helpers
        unless defined? pipeline_filter
          define_method :pipeline_filter do |record|
            pipeline = ::HTML::Pipeline.new([
              Filter::CleanupFilter, 
              Filter::EmbeditorFilter, 
              Filter::InlineAssetsFilter, 
              Filter::AmpFilter
              ], content: record)
            pipeline.call(record)[:output].to_s
          end
          helper_method :pipeline_filter
        end
      end

    end
  end
end

require 'erb'
require 'rack/response'

module Derailed
  module Component
    # = Derailed::Component::View
    # This module generates Rack formatted responses.
    # == Overview:
    # The following Rack responses are available:
    #  render(name, binding) renders the named template using the binding
    #  render_string(string) responds with the given string as the body
    #  redirect(url) redirects to url
    #  not_found(msg) responds with 404 with msg ast the body
    #  method_not_allowed responds with a 405, Method Not Allowed
    #
    # We also have:
    #  render_partial(name) same as render, but returns a string
    #  instead of a rack response (and adds an _ before the name)
    #  It uses current_binding, which is set in render
    #
    # All other functions are internal and not intended to be called outside
    # this module.  Also, render and render_partial will only work within a
    # component... RequestRouter and Manager do not have templates.
    module View
      private
      # Renders a template to a rack response from it's name and a binding
      def render(name, binding)
        string = read_view_file(name)
        Thread.current[:binding] = binding
        result = render_erb(string, binding)
        Thread.current[:binding] = nil
        result
      end
      module_function :render

      # Renders a template to a string from it's name
      def render_partial(name)
        string = read_view_file '_' + name
        execute_template(string, current_binding)
      end
      module_function :render_partial

      # Renders a string
      def render_string(string, headers={})
        render_response string, 200, headers
      end
      module_function :render_string

      # Renders a redirect to the given url
      def redirect(url)
        response = Rack::Response.new
        response.redirect(url)
        status, headers, body = response.finish
        body = body.body
        render_response body, status, headers
      end
      module_function :redirect

      # Renders a 404, Not found with the given message
      def not_found(msg)
        render_response msg, 404
      end
      module_function :not_found

      # Renders a 405, Method not allowed
      def method_not_allowed
        render_response 'Method Not Allowed', 405
      end
      module_function :method_not_allowed

      def internal_error(msg)
        render_response msg, 500
      end
      module_function :internal_error

      # Renders an erb template given as a string using the given binding
      def render_erb(string,b)
        render_response execute_template(string,b)
      end

      # render_response renders the response in Rack format
      def render_response(body, status=200, headers={})
        if body.class != Array
          if status == 200 &&
              params['_ajax'] != 'yes' &&
              !headers.has_key?('Content-Type')
            body = template_wrap(body)
          end
          body = [body]
        end

        [status, headers, body]
      end
      module_function :render_response

      # Executes a template given a string and a binding.  Returns the string
      # result of executing the template
      def execute_template(string, b)
        ERB.new(string).result b
      end

      # current_binding retreives the current binding during template execution
      def current_binding
        Thread.current[:binding]
      end

      # from_binding evaluates code with the current binding
      def from_binding(code)
        eval code, current_binding
      end

      # read_view_file returns the template specified by name as a string
      # ==== example:
      # read_view_file('modelnamelist') returns the contents of
      # component_dir/v/modelnamelist.html.erb
      def read_view_file(name)
        File.read("#{component_dir}/v/#{name}.html.erb")
      end

      # component_dir switches between @name.downcase (when we are called from
      # the component) and @component.name.downcase (when we are called from
      # the controller) to return Config::ComponentDir/componentname
      def component_dir
        dir = Config::ComponentDir + '/'
        if @name
          dir += @name.downcase
        else
          dir += @component.name.downcase
        end
        dir
      end

      # template_wrap wraps the content in the template, using the binding in
      # this function.  This means layouts are limited to the compontent
      # controller level functions, and the content variable
      def template_wrap(content, template='default')
        layout = File.read(Config::RootDir + "/layouts/#{template}.html.erb")
        ERB.new(layout).result binding
      end
    end
  end
end

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
    #  render_partial(name, binding) same as render, but returns a string
    #  instead of a rack response (and adds an _ before the name)
    #
    # All other functions are internal and not intended to be called outside
    # this module.  Also, render will only work within a component...
    # RequestRouter and Manager do not have templates.
    module View
      private
      # Renders a template to a rack response from it's name and a binding
      def render(name, binding)
        string = read_view_file(name)
        render_erb(string, binding)
      end
      module_function :render

      # Renders a template to a string from it's name and a binding
      def render_partial(name, binding)
        string = read_view_file('_' + name)
        execute_template(string, binding)
      end
      module_function :render_partial

      # Renders a string
      def render_string(string)
        [200,
         {'Content-Type' => 'text/html'},
         [string]]
      end
      module_function :render_string

      # Renders a redirect to the given url
      def redirect(url)
        response = Rack::Response.new
        response.redirect(url)
        response.finish
      end
      module_function :redirect

      # Renders a 404, Not found with the given message
      def not_found(msg)
        [404, {'Content-Type' => 'text/html'}, [msg]]
      end
      module_function :not_found

      # Renders a 405, Method not allowed
      def method_not_allowed
        [405, {'Content-Type' => 'text/html'}, ['Method Not Allowed']]
      end
      module_function :method_not_allowed

      # Renders an erb template given as a string using the given binding
      def render_erb(string,b)
        [200,
         {'Content-Type' => 'text/html'},
         [execute_template(string,b)]
        ]
      end

      # Executes a template given a string and a binding.  Returns the string
      # result of executing the template
      def execute_template(string, b)
        ERB.new(string).result b
      end

      # read_view_file returns the template specified by name as a string
      # ==== example:
      # read_view_file('modelnamelist') returns the contents of
      # RootDir/components-enabled/componentname/v/modelnamelist.html.erb
      def read_view_file(name)
        File.read("#{Config::RootDir}/components-enabled/#{component_dir}" +
                  "/v/#{name}.html.erb")
      end

      # component_dir switches between @name.downcase (when we are called from
      # the component) and @component.name.downcase (when we are called from
      # the controller)
      def component_dir
        if @name
          @name.downcase
        else
          @component.name.downcase
        end
      end
    end
  end
end

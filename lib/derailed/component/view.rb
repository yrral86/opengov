require 'erb'
require 'rack/response'

module Derailed
  module Component
    # = Derailed::Component::View
    # This module generates Rack formatted responses.
    module View
      private
      # Renders and erb template given a filename and a binding
      def render_erb_from_file(fn, b)
        string = File.read(fn)
        render_erb(string,b)
      end
      module_function :render_erb_from_file

      # Renders an erb template to a string given a file name and a binding
      def render_erb_from_file_to_string(fn, b)
        string = File.read(fn)
        execute_template(string,b)
      end
      module_function :render_erb_from_file_to_string

      # Renders a string
      def render_string(string)
        [200,
         {'Content-Type' => 'text/html'},
         [string]]
      end
      module_function :render_string

      # Renders an erb template given as a string using the given binding
      def render_erb(string,b)
        [200,
         {'Content-Type' => 'text/html'},
         [execute_template(string,b)]
        ]
      end
      module_function :render_erb

      # Executes a template given a string and a binding.  Returns the string
      # result of executing the template
      def execute_template(string, b)
        ERB.new(string).result b
      end
      module_function :execute_template

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

      # Renders a template from it's name and a binding
      def render(name, binding)
        render_erb_from_file_to_string(view_file('_' + name), binding)
      end

      # view_file returns the filename of a given view
      # ==== example:
      # view_file('modelnamelist') returns
      # RootDir/components-enabled/componentname/v/nodelnamelist.html.erb
      def view_file(name)
        "#{Config::RootDir}/components-enabled/#{component_dir}" +
          "/v/#{name}.html.erb"
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

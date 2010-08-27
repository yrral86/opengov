require 'erb'
require 'rack/response'

module Derailed
  # = Derailed::View
  # This class generates Rack formatted responses.
  class View
    # Renders and erb template given a filename and a binding
    def self.render_erb_from_file(fn, b)
      string = File.read(fn)
      render_erb(string,b)
    end

    # Renders an erb template to a string given a file name and a binding
    def self.render_erb_from_file_to_string(fn, b)
      string = File.read(fn)
      execute_template(string,b)
    end

    # Renders a string
    def self.render_string(string)
      [200,
       {'Content-Type' => 'text/html'},
       [string]]
    end

    # Renders an erb template given as a string using the given binding
    def self.render_erb(string,b)
      [200,
       {'Content-Type' => 'text/html'},
       [execute_template(string,b)]
      ]
    end

    # Executes a template given a string and a binding.  Returns the string
    # result of executing the template
    def self.execute_template(string, b)
      ERB.new(string).result b
    end

    # Renders a redirect to the given url
    def self.redirect(url)
      response = Rack::Response.new
      response.redirect(url)
      response.finish
    end

    # Renders a 404, Not found with the given message
    def self.not_found(msg)
      [404, {'Content-Type' => 'text/html'}, [msg]]
    end

    # Renders a 405, Method not allowed
    def self.method_not_allowed
      [405, {'Content-Type' => 'text/html'}, ['Method Not Allowed']]
    end
  end
end


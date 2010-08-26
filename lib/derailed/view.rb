require 'erb'
require 'rack/response'

module Derailed
  class View
    def self.render_erb_from_file(fn, b)
      string = File.read(fn)
      render_erb(string,b)
    end

    def self.render_erb_from_file_to_string(fn, b)
      string = File.read(fn)
      execute_template(string,b)
    end

    def self.render_string(string)
      [200,
       {'Content-Type' => 'text/html'},
       [string]]
    end

    def self.render_erb(string,b)
      [200,
       {'Content-Type' => 'text/html'},
       [execute_template(string,b)]
      ]
    end

    def self.execute_template(string, b)
      ERB.new(string).result b
    end

    def self.redirect(url)
      response = Rack::Response.new
      response.redirect(url)
      response.finish
    end

    def self.not_found(msg)
      [404, {'Content-Type' => 'text/html'}, [msg]]
    end

    def self.method_not_allowed
      [405, {'Content-Type' => 'text/html'}, ['Method Not Allowed']]
    end
  end
end


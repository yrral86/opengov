module Derailed
  module Component
    # = Derailed::Component::Helpers
    # This module is where our view helpers are defined.
    module Helpers
      private
      # error_box returns a string containing an unordered list of model
      # validation errors
      def error_box(record)
        ul record.errors.full_messages
      end

      # ul turns the given array into an unordered list
      def ul(array, style="default")
        string = "<ul class=\"#{style}\">"
        array.each do |e|
          string += "<li>#{e}</li>"
        end
        string += "</ul>"
      end

      # record_list creates a table for the records in array
      def record_list(array, attributes, style="default")
        model = from_binding('model')
        string = "<table class=\"#{style}\"><tr>"
        attributes.each {|a| string += "<th>#{a[1]}</th>"}
        string += "<th>Actions</th>"
        string += "</tr>"
        array.each do |record|
          string += "<tr>"
          attributes.each {|a| string += "<td>#{record[a[0]]}</td>"}
          string += "<td><a href=\"/#{@component.name.downcase}/#{model.name.downcase}/#{record[:id]}\">Details</a></td>"
          string += "</tr>"
        end
        string += "</table>"
      end

      def javascript
        '<script type="text/javascript" src="/static/javascript/main.js">' +
          '</script>'
      end

      # from_binding evaluates code with the current binding
      def from_binding(code)
        eval code, Thread.current[:binding]
      end
    end
  end
end

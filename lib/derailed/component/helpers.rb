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
        string = "<table class=\"#{style}\"><tr>"
        attributes.each {|a| string += "<th>#{a[1]}</th>"}
        string += "<th>Actions</th>"
        string += "</tr>"
        array.each do |record|
          string += "<tr>"
          attributes.each {|a| string += "<td>#{record[a[0]]}</td>"}
          id = record[:id]
          string += "<td>#{object_details_link(id)}<br />" +
            "#{object_edit_link(id)}<br />" +
            "#{object_delete_link(id)}</td>"
          string += "</tr>"
        end
        string += "</table>"
      end

      def object_link(id = nil)
        c_name = from_binding('@component.name.downcase')
        m_name = from_binding('model.name.downcase')
        id ||= from_binding('object[:id]')
        yield "/#{c_name}/#{m_name}", id
      end

      def object_details_link(id = nil)
        object_link(id) do |base_link, id|
          "<a href=\"#{base_link}/#{id}\">Details</a>"
        end
      end

      def object_delete_link(id = nil)
        object_link(id) do |base_link, id|
          "<a href=\"javascript:delete_object(" +
            "'#{id}','#{base_link}')\">Delete</a>"
        end
      end

      def object_edit_link(id = nil)
        object_link(id) do |base_link, id|
          "<a href=\"#{base_link}/edit/#{id}\">Edit</a>"
        end
      end

      def object_list_link(text = "Return to list")
        object_link(0) do |base_link, id|
          "<a href=\"#{base_link}\">#{text}</a>"
        end
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

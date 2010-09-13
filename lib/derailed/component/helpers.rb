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
      def record_list(attributes, style="default")
        array = from_binding('objects')
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
        string += object_new_link
      end

      def record_details(attributes, style="default")
        object = from_binding('object')
        string = "<table class=\"#{style}\">"
        attributes.each do |a|
          string += "<tr><td>#{a[1]}:</td><td>#{object[a[0]]}</td></tr>"
        end
        string += "</table>"
        string +=
          "#{object_edit_link} #{object_delete_link} #{object_list_link}"
      end

      def form(attributes)
        object = from_binding('object')
        string = error_box(object)
        action = ""
        object_link do |base_link, id|
          action = "#{base_link}/#{id}"
        end
        string += "<form id=\"form\" method=\"post\" " +
          "action=\"#{action}\">" +
          "<input type=\"hidden\" name=\"_method\" " +
          "value=\"#{from_binding('method')}\" />"
        attributes.each do |a|
          string += "#{a[1]}: <input type=\"text\" name=\"#{a[0]}\" " +
            "value=\"#{object[a[0]]}\" /><br />"
        end
        string += "<input type=\"submit\" name=\"Update\" /></form>"
      end

      # obejct_link generates the base URL for model crud links from the current
      # binding and runs the given block yielding that URL and the id
      def object_link(id = nil)
        c_name = from_binding('@component.name.downcase')
        m_name = from_binding('model.name.downcase')
        id ||= from_binding('object[:id]')
        yield "/#{c_name}/#{m_name}", id
      end

      # object_details_link returns a link to the details page for the object
      # identified by id
      def object_details_link(id = nil)
        object_link(id) do |base_link, id|
          a "#{base_link}/#{id}", "Details"
        end
      end

      # object delete link returns a link to delete the object specified by id
      def object_delete_link(id = nil)
        object_link(id) do |base_link, id|
          a "javascript:delete_object(" +
            "'#{id}','#{base_link}')", "Delete"
        end
      end

      # object_edit link returns a link to edit the object specified by id
      def object_edit_link(id = nil)
        object_link(id) do |base_link, id|
          a "#{base_link}/edit/#{id}", "Edit"
        end
      end

      def object_new_link
        name = from_binding('model.name')
        object_link(0) do |base_link, id|
          a "#{base_link}/edit", "New #{name}"
        end
      end

      # object_list_link returns a link to the object list for model crud
      def object_list_link(text = "Return to list")
        object_link(0) do |base_link, id|
          a base_link, text
        end
      end

      def a(url,text)
        "<a href=\"#{url}\">#{text}</a>"
      end

      # javascript includes the main javascript file, which handles
      def javascript
        '<script type="text/javascript" src="/static/javascript/main.js">' +
          '</script>'
      end
    end
  end
end

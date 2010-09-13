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
      def ul(array)
        string = "<ul>"
        array.each do |e|
          string += "<li>#{e}</li>"
        end
        string += "</ul>"
      end
    end
  end
end

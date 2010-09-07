module Derailed
  module Component
    # = Derailed::Component::Helpers
    # This module is where our view helpers are defined.
    module Helpers
      private

      # error_box returns a string containing an unordered list of model
      # validation errors
      def error_box(record)
        string = "<ul>"
        record.errors.full_messages.each do |m|
          string += "<li>#{m}</li>"
        end
        string += "</ul>"
      end
    end
  end
end

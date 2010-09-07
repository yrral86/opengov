#require 'action_view/helpers'

module Derailed
  module Component
    # = Derailed::Component::Helpers
    # This module includes ActionView::Helpers, but only some of them work
    # without an ActionController.  It is also where our helpers are defined.
    module Helpers
      private
 #     include ActionView::Helpers

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

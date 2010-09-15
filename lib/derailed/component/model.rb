require 'rubygems'
require 'active_record'
require 'drb'

module Derailed
  module Component
    # = Derailed::Component::Model
    # This class is an ActiveRecord::Base sublass that adds some extra
    # functionality component models need: an abstract_map that allows the
    # model to act as an abstract data type, and we include DRbUndumped so
    # the model is kept in the Component's process and interacted with over
    # the socket.
    class Model < ActiveRecord::Base
      def self.full_model_name=(name)
        @full_model_name = name
      end

      def self.full_model_name
        @full_model_name
      end

      def full_model_name
        self.class.full_model_name
      end

      # required to subclass ActiveRecord::Base without it trying to
      # find a 'model' table
      self.abstract_class = true

      # abstract_map provides a map from the db fields to the abstract datatype
      # fields
      def abstract_map
        {} # return empty hash, db fields align with abstract fields
      end

      # self.abstract_type specifies the abstract data type this model
      # implements (default: nil)
      def self.abstract_type
        nil
      end

      # forces model objects to be sent over the socket as references
      # instead of copied... if they are copied, they won't have their
      # DB connection... and we want to keep DB interactions local anyway
      include DRbUndumped
    end
  end
end

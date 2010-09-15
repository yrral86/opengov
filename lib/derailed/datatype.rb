module Derailed
  # = Derailed::DataType
  # This class is the base class for data types.  A subclass has a class-level
  # hash named 'fields' that contains the attributes and names of the type.  A
  # model which implements the type, has two methods:
  # 1. abstract_map, which is a hash with maps any abstract attributes that
  #    don't have the same name as database fields to the appropriate field.
  # 2. self.abstract_type, which specifies the name of the type implemented in
  #    CamelCase.
  # ==== example:
  #   module Type
  #     class Primate < DataType
  #       @fields = {
  #         :first_name => 'First Name',
  #         :last_name => 'Last Name',
  #         :age => 'Age'
  #       }
  #     end
  #   end
  #
  #   class Person < Derailed::Component::Model
  #     def abstract_map
  #       {:age => :years} # db field is 'years'
  #     end
  #
  #     def self.abstract_type
  #       'Primate'
  #     end
  #   end
  #
  # ===== Usage:
  #  p = Person.new({:first_name => 'Bob', :last_name => 'Smith', :years => 23})
  #  primate = Type::Primate.new(p)
  #  primate.age
  #  > 23
  class DataType
    include DRbUndumped

    # initialize sets the record class variable to the first parameter.
    def initialize(record)
      @record = record
    end

    # [] calls method_missing so record[:attribute] works
    def [](id)
      method_missing(id)
    end

    # full_model_name gives us access to the full model name stored in the
    # record's class
    def full_model_name
      @record.remote_class.full_model_name
    end

    # method_missing sends the requested attribute to the record unless there is
    # a match in the abstract map that overrides the attribute name, in which
    # case that name is sent.
    def method_missing(id, *args)
      target = @record.abstract_map[id]
      if target
        @record.send(target, *args)
      else
        @record.send(id, *args)
      end
    end
  end
end

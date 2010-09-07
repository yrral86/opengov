module Derailed
  module Type
    # = Derailed::Type::Person
    # This class defines the Person abstract data type
    class Person < DataType
      @fields = {
        :first_name => 'First Name',
        :last_name => 'Last Name'
      }
    end
  end
end

module Derailed
  module Type
    class Person < DataType
      @fields = {
        :first_name => 'First Name',
        :last_name => 'Last Name'
      }
    end
  end
end

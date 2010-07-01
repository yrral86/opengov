require 'lib/datatype'

class OpenGovPerson < OpenGovDataType
  @fields = {
    'the_firstest_name' => 'First Name',
#    'fname' => 'First Name',
    'lname' => 'Last Name'
  }
end

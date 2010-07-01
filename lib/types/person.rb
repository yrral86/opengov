require 'lib/datatype'

class OpenGovPerson < OpenGovDataType
  @fields = {
    :id => 'Id',
    :the_firstest_name => 'First Name',
#    'fname' => 'First Name',
    :lname => 'Last Name'
  }
end

[
'config',
'componentclient',
'datatype',
'type/person.rb',
'manager/socket',
'component/base',
].each do |library|
  require "derailed/#{library}"
end

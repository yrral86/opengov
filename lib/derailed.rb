[
'config',
'componentclient',
'datatype',
'type/person.rb',
'manager/interface',
'component/base',
].each do |library|
  require "derailed/#{library}"
end

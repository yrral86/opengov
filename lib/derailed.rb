[
'config',
'componentclient',
'datatype',
'type/person.rb',
'manager/interface',
'requestrouter',
'component/base',
'controller/middleware'
].each do |library|
  require "derailed/#{library}"
end

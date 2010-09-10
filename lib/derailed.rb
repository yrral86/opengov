[
'config',
'componentclient',
'datatype',
'type/person.rb',
'manager/interface',
'requestrouter',
'component/base',
'component/authenticator',
'component/authenticatorcontroller',
'controller/middleware'
].each do |library|
  require "derailed/#{library}"
end

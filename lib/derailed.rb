[
 'config',
 'componentclient',
 'datatype',
 'service',
 'type/person.rb',
 'manager/socket',
 'component/base',
].each do |library|
  require "derailed/#{library}"
end

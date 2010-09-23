[
 'config',
 'componentclient',
 'datatype',
 'service',
 'type/person.rb',
 'component/base',
].each do |library|
  require "derailed/#{library}"
end

[
 'config',
 'client',
 'datatype',
 'servedobject',
 'service',
 'type/person.rb',
 'component/base',
].each do |library|
  require "derailed/#{library}"
end

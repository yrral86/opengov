[
 'util',
 'config',
 'data_type',
 'keys',
 'served_object',
 'service',
 'type/person.rb',
 'component/base',
].each do |library|
  require "derailed/#{library}"
end

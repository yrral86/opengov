# updatewatcher.rb
require 'rubygems'
require 'sinatra'

versions = {0 => 0, 1 => 1, 2 => 2, 3 => 3, 4 => 4}

# read
get '/:id' do |id|
  if versions[id.to_i] then
    versions[id.to_i].to_s
  else
    status 404
    "Version ##{id} not found"
  end
end

# create
post '/:id' do |id|
  if versions[id.to_i] then
    status 409
    "Version ##{id} already exists"
  else
    versions[id.to_i] = params[:version].to_i
  end
end

# update
put '/:id' do |id|
  if versions[id.to_i] then
    versions[id.to_i] = params[:version].to_i
    "Version ##{id} updated"
  else
    status 404
    "Version ##{id} not found"
  end
end

# delete
delete '/:id' do |id|
  if versions.delete(id.to_i) then
    "Version ##{id} deleted"
  else
    status 404
    "Version ##{id} not found"
  end
end

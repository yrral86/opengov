require 'drb'

class OpenGovDataType
  include DRbUndumped

  def initialize(record)
    @record = record
  end

  def method_missing(id, *args)
    target = @record.abstract_map[id.id2name]
    if target then
      @record.send(target, *args)
    else
      @record.send(id, *args)
    end
  end
end

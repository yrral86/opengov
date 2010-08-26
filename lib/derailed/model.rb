require 'rubygems'
require 'active_record'
require 'drb'

module Derailed
  class Model < ActiveRecord::Base
    # required to subclass ActiveRecord::Base without it trying to
    # find an open_gov_model table
    self.abstract_class = true

    def abstract_map
      {} # return empty hash, db fields align with abstract fields
    end

    # forces model objects to be sent over the socket as references
    # instead of copied... if they are copied, they won't have their
    # DB connection... and we want to keep DB interactions on the
    # server anyway
    include DRbUndumped
  end
end

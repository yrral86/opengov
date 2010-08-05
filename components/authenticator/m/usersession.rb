require 'authlogic'
require 'authlogic_pam'
require 'drb'

dir = File.expand_path(File.dirname(__FILE__))

class UserSession < Authlogic::Session::Base
  attr_accessor :new_record

  include DRbUndumped

  def initialize(*args)
    super(*args)
    @new_record = true
  end

  def save_with_mark
    @new_record = false
    save_without_mark
  end
  alias_method_chain :save, :mark
end

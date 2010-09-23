# for some reason on the server authlogic_pam wasn't updating the persistence token
# and this fixes it... probably a better way when we have time to research
module FixAuthlogicPamSaveRecord
  def self.included(klass)
    klass.class_eval do
      alias_method_chain :save_record, :hack
    end
  end


  def save_record_with_hack(attempted_record = nil)
    attempted_record.reset_persistence_token if attempted_record && !attempted_record.changed?
    save_record_without_hack(attempted_record)
  end
end


class UserSession < Authlogic::Session::Base
  include DRbUndumped
  include FixAuthlogicPamSaveRecord
end

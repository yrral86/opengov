class Message < Derailed::Component::Model
  belongs_to :recepient, :foreign_key => :to_id, :class_name => 'User'
  belongs_to :sender, :foreign_key => :from_id, :class_name => 'User'
end

class User < Derailed::Component::ModelProxy
  self.initProxy 'Authenticator::User'
end

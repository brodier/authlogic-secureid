require 'authlogic_secureid/acts_as_authentic'
require 'authlogic_secureid/session'

module AuthlogicSecureId
  VERSION = '0.0.0'
end

Authlogic::Session::Base.send(:include, AuthlogicSecureId::Session)

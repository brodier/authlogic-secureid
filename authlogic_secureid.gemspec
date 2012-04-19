Gem::Specification.new do |s|
  s.name        = 'authlogic_secureid'
  s.version     = '1.0.0'
  s.date        = '2010-04-28'
  s.require_paths = ["lib"]
  s.summary     = "Authlogic pluggin to used pam secureid module"
  s.description = "Authlogic extention to used pam secureid module"
  s.authors     = ["Bernard Rodier"]
  s.email       = 'bernard.rodier@gmail.com'
  s.files       = Dir['lib/**/*']
  s.files = ["lib/authlogic_secureid.rb","lib/authlogic_secureid/session.rb",
             "lib/authlogic_secureid/acts_as_authentic.rb","ext/RpamSecureID/rpam.c", 
             "ext/RpamSecureID/extconf.rb", "authlogic_secureid.gemspec", "README.rdoc", "LICENSE"]
  s.extensions = ["ext/RpamSecureID/extconf.rb"]
  s.homepage    =
    'http://rubygems.org/gems/authologic_secureid'
end

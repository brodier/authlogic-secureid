require 'rpam_secureid'

module AuthlogicSecureId
  module Session
    def self.included(klass)
      klass.class_eval do
        extend Config
        include Methods
        include RpamSecureID
        
        validate :validate_by_pam, :if => :authenticating_with_pam?
      end
    end
    
    module Config
      def find_by_pam_login_method(value = nil)
        rw_config(:find_by_pam_login_method, value, :find_by_pam_login)
      end
      alias_method :find_by_pam_login_method=, :find_by_pam_login_method
    end
    
    module Methods
      def self.included(klass)
        klass.class_eval do
          attr_accessor :pam_login
          attr_accessor :password
        end
      end
      
      def credentials
        if authenticating_with_pam?
          details = {}
          details[:login] = send(login_field)
          details[:password] = '<protected>'
          details
        else
          super
        end
      end
      
      def credentials=(value)
        super
        values = value.is_a?(Array) ? value : [value]
        hash = values.first.is_a?(Hash) ? values.first.with_indifferent_access : nil
        if !hash.nil?
          self.pam_login = hash[:login] if hash.key?(:login)
          self.password = hash[:password] if hash.key?(:password)
        end
      end

    private
      def authenticating_with_pam?
        !login.blank? && !password.blank?
      end
      
      # override validate_by_password when RSA PAM SecureId is installing
      def validate_by_password
        true
      end
      
      def find_by_pam_login_method
        self.class.find_by_pam_login_method
      end
      
      def validate_by_pam
        if login.blank?
          errors.add(:pam_login, I18n.t('error_messages.login_blank', :default => 'cannot be blank'))
        elsif pam_login.blank?
          attempt = klass.find_by_login(login)
          errors.add(:login, 'Invalid Login')  if attempt.nil?
          pam_login = attempt.pam_login
          errors.add(:pam_login, I18n.t('error_messages.pam_login_blank', :default => 'cannot be blank'))  if pam_login.blank?
        end
        
        errors.add(:password, I18n.t('error_messages.password_blank', :default => 'cannot be blank')) if password.blank?
       
        return if errors.count > 0
        
        if pam_login.nil?
          attempt = klass.find_by_login(login)
          pam_login = attempt.pam_login
        end
        
        if pam_login.nil?
          raise "Error pam_login is nil user : #{attempt.login} pam_login= #{attempt.pam_login}"
        end
        
        if auth_secureid(pam_login, password)
          self.attempted_record = klass.find_by_login(login)
          errors.add(:login, I18n.t('error_messages.login_not_found', :default => "does not exist")) if attempted_record.blank?
        else
          errors.add(:password, "PAM RSA SecureID authentication failed")
        end
      end
    end
  end
end

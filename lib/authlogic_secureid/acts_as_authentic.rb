module AuthlogicSecureId
  module ActsAsAuthentic
    def self.included?(klass)
      klass.class_eval do
        extend Config
        add_acts_as_authentic_module(Methods, :prepend)
      end
    end
    
    module Config
      def validate_pam_login(value = nil)
        config(:validate_pam_login, value, true)
      end
      alias_method :validate_pam_login=, :validate_pam_login
    end
    
    module Methods
      def self.included?(klass)
        klass.class_eval do
          attr_accessor :password
          
          if validate_pam_login
            validates_uniqueness_of :login, :scope => validations_scope, :if => :using_pam?
            validates_presence_of :password, :if => :validate_pam?
            validate :validate_pam, :if => :validate_pam?
          end
        end
      end
      
      private
      def using_pam?
        respond_to?(:login) && respond_to?(:password)
      end
      
      def validate_pam
        return if errors.count > 0
      end
      
      def validate_pam?
        login_changed? && !login.blank?
      end
    end
  end
end

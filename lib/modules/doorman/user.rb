module Sinatra
  module Doorman
    class User
      include Mongoid::Document
      include Sinatra::Doorman::TrackedEntity
      include BCrypt
      store_in collection: 'users'

      field :username,              type: String
      field :password,              type: String
      field :salt,                  type: String
      field :first_name,            type: String, :default => ''
      field :last_name,             type: String, :default => ''
      field :mobile,                type: String, :default => ''

      field :title,                 type: String, :default => Sinatra::Doorman::Utils::Titles::APPRENTICE
      field :role,                  type: Symbol, :default => Sinatra::Doorman::Utils::Roles::ADMIN

      field :confirmed,             type: Boolean, :default => true
      field :confirm_token,         type: String
      field :remember_token,        type: String

      field :created_from,          type: Symbol
      field :created_at,            type: DateTime
      field :last_login,            type: DateTime

      attr_accessor :password_confirmation

      validates_presence_of :username
      validates_presence_of :password
      #attr_protected :salt

      before_save :validate!

      def self.make(opts)
        if User.where(:username => opts[:username]).exists?
          raise Obscured::DomainError.new(:already_exists, what: 'user')
        end

        user = self.new
        user.username = opts[:username]
        user.password = Password.create(opts[:password])
        user.set_created_by(Sinatra::Doorman::Utils::Types::SYSTEM)
        user.add_history_log('User created', Sinatra::Doorman::Utils::Types::SYSTEM)
        user
      end

      def self.make_and_save(opts)
        user = self.make(opts)
        user.save
      end

      class << self
        def get(id)
          self.where(:_id => id).first
        end

        def get_by_username(username)
          #treat username as email address
          self.where(:username => username).first
        end
      end


      def name
        return "#{self.first_name} #{self.last_name}"
      end

      def set_username(username)
        if User.where(:username => username).exists?
          raise Obscured::DomainError.new(:already_exists, what: 'user')
        end

        self.username = username
      end

      def set_name(first_name, last_name)
        self.first_name = first_name
        self.last_name = last_name
      end

      def set_role(role)
        self.role = role
      end

      def set_title(title)
        self.title = title
      end

      def set_mobile(mobile)
        self.mobile = mobile
      end

      def set_created_by(created_by)
        self.created_by = created_by
      end

      def set_password(password)
        self.password = Password.create(password)
        self.add_history_log('Password has been changed', Sinatra::Doorman::Utils::Types::SYSTEM)
      end

      def set_created_from(created_from)
        raise Obscured::DomainError.new(:created_from_already_set) unless self[:created_from].blank?
        self.created_from = created_from
      end

      def self.authenticate(username, password)
        user = self.get_by_username(username)
        return user if user && user.authenticated?(password)
        return nil
      end

      def authenticated?(password)
        db_password = Password.new(self.password)
        if db_password == password
          true
        else
          false
        end
      end

      def remember_me!
        self.remember_token = new_token
        self.save
      end

      def forget_me!
        self.remember_token = nil
        self.save
      end

      def confirm_email!
        self.confirmed     = true
        self.confirm_token = nil
        self.save
      end

      def forgot_password!
        self.confirm_token = new_token
        self.save
      end

      def remembered_password!
        self.confirm_token = nil
        self.save
      end

      def reset_password!(new_password, new_password_confirmation)
        unless new_password == new_password_confirmation
          false
        else
          self.password_confirmation  = new_password_confirmation
          self.password               = Password.create(new_password) if valid?
          self.add_history_log('Password has been reset', Sinatra::Doorman::Utils::Types::HOMER)
          self.save
        end
      end


      protected
      def salt
        if @salt.nil? || @salt.empty?
          secret    = Digest::SHA1.hexdigest("--#{Time.now.utc}--")
          self.salt = Digest::SHA1.hexdigest("--#{Time.now.utc}--#{secret}--")
        end
        @salt
      end

      def encrypt(string)
        Digest::SHA1.hexdigest("--#{salt}--#{string}--")
      end

      def new_token
        encrypt("--#{Time.now.utc}--")
      end

      def validate!
        if valid?
          #self.password = Password.create(password)
          self.confirm_token = new_token
        end
      end
    end
  end
end
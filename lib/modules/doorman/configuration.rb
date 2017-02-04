module Obscured
  module Doorman
    ##
    # Configuration options should be set by passing a hash:
    #
    #   Geocoder.configure(
    #     :confirmation   => false,
    #     :registration   => true,
    #     :smtp_domain    => "domain.tld",
    #     :smtp_username  => "username",
    #     :smtp_password  => "password",
    #   )
    #
    def self.configure(options = nil, &block)
      if !options.nil?
        Configuration.instance.configure(options)
      end
    end

    ##
    # Read-only access to the singleton's config data.
    #
    def self.config
      Configuration.instance.data
    end

    ##
    # Read-only access to lookup-specific config data.
    #
    def self.config_for_lookup(lookup_name)
      data = config.clone
      data.reject!{ |key,value| !Configuration::OPTIONS.include?(key) }
      if config.has_key?(lookup_name)
        data.merge!(config[lookup_name])
      end
      data
    end

    ##
    # Merge the given hash into a lookup's existing configuration.
    #
    def self.merge_into_lookup_config(lookup_name, options)
      base = Geocoder.config[lookup_name]
      Geocoder.configure(lookup_name => base.merge(options))
    end

    class Configuration
      include Singleton

      OPTIONS = [
        :confirmation,
        :registration,
        :smtp_domain,
        :smtp_server,
        :smtp_port,
        :smtp_username,
        :smtp_password,
        :paths
      ]

      attr_accessor :data

      def self.set_defaults
        instance.set_defaults
      end

      OPTIONS.each do |o|
        define_method o do
          @data[o]
        end
        define_method "#{o}=" do |value|
          @data[o] = value
        end
      end

      def configure(options)
        @data.rmerge!(options)
      end

      def initialize # :nodoc
        @data = Obscured::Doorman::ConfigurationHash.new
        set_defaults
      end

      def set_defaults
        @data[:confirmation]      = false                 # Enables/disables if account confirmation is necessary
        @data[:registration]      = false                 # Enables/disables if registration is possible

        @data[:smtp_address]      = 'smtp.sendgrid.net'   # SMTP Address, uses the  address for SendGrid
        @data[:smtp_password]     = nil                   # SMTP Password
        @data[:smtp_port]         = '587'                 # SMTP Port, uses the recommended port for SendGrid
        @data[:smtp_server]       = nil                   # SMTP Server
        @data[:smtp_username]     = nil                   # SMTP Username

        @data[:remember_for]      = 14                    # Setting the amount of days "Remember me" is valid
        @data[:use_referrer]      = true                  # Setting this to true will store last request URL
                                                          # into a user's session so that to redirect back to it
                                                          # upon successful authentication

        @data[:paths]             = { :success => '/home',
                                      :login => '/doorman/login',
                                      :logout => '/doorman/logout',
                                      :forgot => '/doorman/forgot',
                                      :reset => '/doorman/reset' }
      end

      instance_eval(OPTIONS.map do |option|
        o = option.to_s
        <<-EOS
      def #{o}
        instance.data[:#{o}]
      end

      def #{o}=(value)
        instance.data[:#{o}] = value
      end
        EOS
      end.join("\n\n"))
    end


    class ConfigurationHash < Hash
      include HashRecursiveMerge

      def method_missing(meth, *args, &block)
        has_key?(meth) ? self[meth] : super
      end
    end
  end
end
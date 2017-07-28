module Obscured
  module AptWatcher
    module Models
      class Configuration
        include Mongoid::Document
        include Mongoid::Timestamps
        store_in collection: 'configuration'

        field :instance,          type: String, :default => ''

        field :api_username,      type: String, :default => ''
        field :api_password,      type: String, :default => ''
        field :user_registration, type: Boolean, :default => false
        field :user_confirmation, type: Boolean, :default => false

        field :bitbucket_enabled, type: Boolean, :default => false
        field :bitbucket_key,     type: String, :default => ''
        field :bitbucket_secret,  type: String, :default => ''

        field :github_enabled,    type: Boolean, :default => false
        field :github_key,        type: String, :default => ''
        field :github_secret,     type: String, :default => ''


        field :slack_enabled,     type: Boolean, :default => false
        field :slack_channel,     type: String, :default => ''
        field :slack_icon,        type: String, :default => ':slack:'
        field :slack_user,        type: String, :default => 'AptWatcher'
        field :slack_webhook,     type: String

        field :smtp_enabled,      type: Boolean, :default => false
        field :smtp_domain,       type: String, :default => ''
        field :smtp_host,         type: String, :default => 'smtp.sendgrid.net'
        field :smtp_port,         type: Integer, :default => 587
        field :smtp_username,     type: String
        field :smtp_password,     type: String

        field :raygun_enabled,    type: Boolean, :default => false
        field :raygun_key,        type: String

        index({ instance: 1 }, { background: true })


        def self.make(opts)
          if Configuration.where(:instance => opts[:instance]).exists?
            raise Obscured::DomainError.new(:already_exists, what: 'Configuration does already exists!')
          end

          config = self.new
          config
        end
      end
    end
  end
end
module Obscured
  module AptWatcher
    module Models
      class Configuration
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'configuration'

        field :instance, type: String, :default => ''
        field :setup_completed, type: Boolean, :default => false
        field :user_registration, type: Boolean, :default => false
        field :user_confirmation, type: Boolean, :default => false

        index({ instance: 1 }, { background: true })

        embeds_one :api, :class_name => 'Obscured::AptWatcher::Models::APIConfiguration', autobuild: true
        embeds_one :slack, :class_name => 'Obscured::AptWatcher::Models::SlackConfiguration', autobuild: true
        embeds_one :smtp, :class_name => 'Obscured::AptWatcher::Models::SMTPConfiguration', autobuild: true
        embeds_one :raygun, :class_name => 'Obscured::AptWatcher::Models::RaygunConfiguration', autobuild: true
        embeds_one :bitbucket, :class_name => 'Obscured::AptWatcher::Models::BitbucketConfiguration', autobuild: true
        embeds_one :github, :class_name => 'Obscured::AptWatcher::Models::GitHubConfiguration', autobuild: true

        validates_presence_of :api
        validates_presence_of :slack
        validates_presence_of :smtp
        validates_presence_of :raygun
        validates_presence_of :bitbucket
        validates_presence_of :github

        before_update do |document|
          document.setup_completed = true
        end


        class << self
          def make(opts)
            if Configuration.where(:instance => opts[:instance]).exists?
              raise Obscured::DomainError.new(:already_exists, what: 'Configuration does already exists!')
            end

            doc = self.new
            doc
          end
          def make!(opts)
            doc = make(opts)
            doc.save
            doc
          end
        end
      end


      class APIConfiguration
        include Mongoid::Document

        field :username,      type: String, :default => ''
        field :password,      type: String, :default => ''

        embedded_in :configuration, autobuild: true
      end

      class SlackConfiguration
        include Mongoid::Document

        field :enabled,     type: Boolean, :default => false
        field :channel,     type: String, :default => ''
        field :icon,        type: String, :default => ':slack:'
        field :user,        type: String, :default => 'AptWatcher'
        field :webhook,     type: String

        embedded_in :configuration, autobuild: true
      end

      class SMTPConfiguration
        include Mongoid::Document

        field :enabled,      type: Boolean, :default => false
        field :domain,       type: String, :default => ''
        field :host,         type: String, :default => 'smtp.sendgrid.net'
        field :port,         type: Integer, :default => 587
        field :username,     type: String
        field :password,     type: String

        embedded_in :configuration, autobuild: true
      end

      class RaygunConfiguration
        include Mongoid::Document

        field :enabled,    type: Boolean, :default => false
        field :key,        type: String

        embedded_in :configuration, autobuild: true
      end

      class BitbucketConfiguration
        include Mongoid::Document

        field :enabled,    type: Boolean, :default => false
        field :key,        type: String, :default => ''
        field :secret,     type: String, :default => ''
        field :domains,     type: String, :default => ''

        embedded_in :configuration, autobuild: true
      end

      class GitHubConfiguration
        include Mongoid::Document

        field :enabled,    type: Boolean, :default => false
        field :key,        type: String, :default => ''
        field :secret,     type: String, :default => ''
        field :domains,     type: String, :default => ''

        embedded_in :configuration, autobuild: true
      end
    end
  end
end
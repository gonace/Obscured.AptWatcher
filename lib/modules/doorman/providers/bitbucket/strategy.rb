require 'warden'
require File.expand_path('../messages', __FILE__)

module Obscured
  module Doorman
    module Providers
      module Bitbucket
        class Strategy < Warden::Strategies::Base
          def valid?
            emails = Bitbucket.config[:token].emails

            if Bitbucket.config.valid_domains.nil?
              return true unless emails.empty?
            else
              return true if valid_domain!
            end

            fail!(Bitbucket::MESSAGES[:invalid_domain])
            false
          end

          def authenticate!
            user = User.where(:username.in => Bitbucket.config[:token].emails).first

            if user.nil?
              fail!(Obscured::Doorman::MESSAGES[:login_bad_credentials])
            elsif !user.confirmed
              fail!(Obscured::Doorman::MESSAGES[:login_not_confirmed])
            else
              success!(user)
            end
          end


          private

          def valid_domain!
            emails = Bitbucket.config[:token].emails || []
            domains = Bitbucket.config.valid_domains.split(',')

            emails.each do |email|
              unless domains.detect { |domain| email.end_with?(domain) } == nil
                return true
              end
            end
            false
          end
        end
      end
    end
  end
end
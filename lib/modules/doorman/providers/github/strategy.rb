require File.expand_path('../messages', __FILE__)

module Obscured
  module Doorman
    module Providers
      module GitHub
        class Strategy < Warden::Strategies::Base
          def valid?
            unless GitHub.config.valid_domains.nil?
              if valid_domain!
                return true
              end
            else
              if emails.length > 0
                return true
              end
            end

            fail!(GitHub::Messages[:invalid_domain])
            return false
          end

          def authenticate!
            user = User.where(:username.in => GitHub.config[:token].emails).first

            if user.nil?
              fail!(Obscured::Doorman::Messages[:login_bad_credentials])
            elsif !user.confirmed
              fail!(Obscured::Doorman::Messages[:login_not_confirmed])
            else
              success!(user)
            end
          end

          private
          def valid_domain!
            emails = GitHub.config[:token].emails || []
            domains = GitHub.config.valid_domains.split(',')

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
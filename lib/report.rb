# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Lib
      class Report
        attr_reader :changes

        def initialize(host, packages)
          @host = host
          @packages = packages
          @changes = packages - host.packages
        end

        def save
          if @changes.any? && SlackClient
            Thread.start do
              SlackClient.ping "#{@host.name} has pending package updates:\n#{@changes.join("\n")}"
            end
          end

          @host.update(packages: @packages, last_report_at: Time.now)
        end
      end
    end
  end
end

# frozen_string_literal: true

module Obscured
  module AptWatcher
    module Controllers
      module Api
        class Scan < Obscured::AptWatcher::Controllers::Api::Base
          get '/' do
            content_type :json

            begin
              Obscured::AptWatcher::Models::Scan.all.to_json
            rescue => e
              Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))

              { success: false, logged: true, message: e.message, backtrace: e.backtrace }.to_json
            end
          end

          get '/:id' do
            content_type :json

            begin
              Obscured::AptWatcher::Models::Scan.where(id: params[:id]).to_json
            rescue => e
              Obscured::AptWatcher::Models::Error.make!(notifier: Obscured::Alert::Type::SYSTEM, message: e.message, backtrace: e.backtrace.join('<br />'))

              { success: false, logged: true, message: e.message, backtrace: e.backtrace }.to_json
            end
          end
        end
      end
    end
  end
end

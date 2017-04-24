module Obscured
  module AptWatcher
    module Controllers
      module Api
        class Matcher < Obscured::AptWatcher::Controllers::Api::Base
          get '/:hostname/:date_start/:date_end' do
            content_type :json

            begin
              raise Obscured::DomainError.new(:required_field_missing, what: ':hostname') if params[:hostname].empty?
              raise Obscured::DomainError.new(:required_field_missing, what: ':date_start') if params[:date_start].empty?
              raise Obscured::DomainError.new(:required_field_missing, what: ':date_end') if params[:date_end].empty?

              Obscured::AptWatcher::Package::Matcher.run(params[:hostname], params[:date_start], params[:date_end]).to_json
            rescue => e
              Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
              {:success => false, :logged => true, :message => e.message, :backtrace => e.backtrace}.to_json

              Raygun.track_exception(e)
            end
          end
        end
      end
    end
  end
end
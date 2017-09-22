module Obscured
  module AptWatcher
    module Controllers
      class Scan < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/scan'


        get '/:id' do
          authorize!
          raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?

          scan = Obscured::AptWatcher::Models::Scan.find(params[:id]) rescue redirect('/')
          host = Obscured::AptWatcher::Models::Host.where(:hostname => scan.hostname).first
          alerts = Obscured::AptWatcher::Models::Alert.where(:hostname => scan.hostname, :status => Obscured::Status::OPEN).order_by(created_at: :desc)
          installed = scan.get_installed

          haml :index, :locals => { :host => host, :scan => scan, :alerts => alerts.count, :installed => installed.count }
        end
      end
    end
  end
end
module Obscured
  module AptWatcher
    module Controllers
      class Host < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/host'


        get '/:id' do
          authorize!
          raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?

          host = Obscured::AptWatcher::Models::Host.find(params[:id]) rescue redirect('/')
          scans = Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname).order_by(created_at: :desc).limit(10)

          alerts = Obscured::AptWatcher::Models::Alert.where(:hostname => host.hostname).order_by(created_at: :desc).limit(10)
          alerts_open = Obscured::AptWatcher::Models::Alert.where(:hostname => host.hostname, :status => Obscured::Status::OPEN).order_by(created_at: :desc).count
          alerts_closed = Obscured::AptWatcher::Models::Alert.where(:hostname => host.hostname, :status => Obscured::Status::CLOSED).order_by(created_at: :desc).count

          graph_alerts = {}
          graph_updates = {}
          today = Date.today
          (today - 7.days .. today).each do |date|
            count = 0
            scan = Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).first

            unless scan.nil?
              count = scan.updates_pending
            end

            (graph_updates['header'] ||= []) << date.strftime('%a %d')
            (graph_updates['data'] ||= []) << count


            a_open = Obscured::AptWatcher::Models::Alert.where(:hostname => host.hostname, :status => Obscured::Status::OPEN, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count
            a_closed = Obscured::AptWatcher::Models::Alert.where(:hostname => host.hostname, :status => Obscured::Status::CLOSED, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count
            (graph_alerts['header'] ||= []) << date.strftime('%a %d')
            (graph_alerts['data'] ||= [[],[]]).first << a_open
            (graph_alerts['data'] ||= [[],[]]).last << a_closed
          end

          haml :index, :locals => { :host => host,
                                    :scans => scans,
                                    :alerts => alerts,
                                    :alerts_open => alerts_open,
                                    :alerts_closed => alerts_closed,
                                    :graph_alerts => graph_alerts,
                                    :graph_updates => graph_updates }
        end

        get '/:id/edit' do
          authorize!

          begin
            raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?

            host = Obscured::AptWatcher::Models::Host.find(params[:id]) rescue redirect('/')

            haml :edit, :locals => { :host => host }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})

            flash[:generic_error] = 'An unknown error occurred!'
            redirect "/host/#{params[:id]}"
          end
        end

        post '/:id/edit' do
          authorize!

          begin
            raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?
            host_hostname,host_environment = params.delete('host_hostname'), params.delete('host_environment')
            host_description = params.delete('host_description')

            host = Obscured::AptWatcher::Models::Host.find(params[:id]) rescue redirect('/')

            unless host_hostname.empty?
              unless host_hostname == host.hostname
                host.hostname = host_hostname
              end
            end
            unless host_environment.empty?
              unless host_environment == host.environment
                host.environment = host_environment
              end
            end
            unless host_description.empty?
              unless host_description == host.description
                host.description = host_description
              end
            end
            host.save

            flash[:save_ok] = "We're glad to announce that we could successfully save the changes for (#{host.hostname})"
            redirect "/host/#{host.id}/edit"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})

            flash[:generic_error] = 'An unknown error occurred!'
            redirect "/host/#{params[:id]}"
          end
        end
      end
    end
  end
end
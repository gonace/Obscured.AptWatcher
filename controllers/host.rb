module Obscured
  module AptWatcher
    module Controllers
      class Host < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/host'


        get '/list' do
          authorize!

          begin
            limit = params[:limit] ? Integer(params[:limit]) : 30
            hosts = Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).limit(limit)
            model = Obscured::AptWatcher::Pagination.new(hosts, Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).count)

            haml :list, :locals => {
              :model => model
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = 'An unknown error occurred!'
            redirect '/users'
          end
        end

        get '/list/:page' do
          authorize!

          begin
            raise ArgumentError, 'No page number provided' unless params[:page]

            page = Integer(params[:page])
            limit = params[:limit] ? Integer(params[:limit]) : 30
            skip = (limit*page)-limit

            hosts = Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).skip(skip).limit(limit)
            model = Obscured::AptWatcher::Pagination.new(hosts, Obscured::AptWatcher::Models::Host.order_by(:hostname.asc).count, page)

            partial :'partials/list', :locals => {
              :id => 'hosts',
              :url => '/hosts',
              :model => model
            }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            {success: false, error: e.message}
          end
        end

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

          haml :index, :locals => {
            :host => host,
            :scans => scans,
            :alerts => alerts,
            :alerts_open => alerts_open,
            :alerts_closed => alerts_closed,
            :graph_alerts => graph_alerts,
            :graph_updates => graph_updates
          }
        end

        get '/:id/edit' do
          authorize!

          begin
            raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?

            host = Obscured::AptWatcher::Models::Host.find(params[:id]) rescue redirect('/')

            haml :edit, :locals => { :host => host }
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = e.message
            redirect "/host/#{params[:id]}"
          end
        end

        post '/create' do
          authorize!

          #begin
            values = params.except(:tags)
            host = Obscured::AptWatcher::Models::Host.make!(values)

            params[:tags].split(",").each do |name|
              tag = Obscured::AptWatcher::Models::Tag.upsert!(name: name, type: :default)
              host.add_tag(tag)
            end
            host.save

            redirect "/host/list"
          #rescue => e
          #  Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
          #  flash[:error] = e.message
          #  redirect "/host/list"
          #end
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

            flash[:success] = "We're glad to announce that we could successfully save the changes for (#{host.hostname})"
            redirect "/host/#{host.id}/edit"
          rescue => e
            Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            flash[:error] = 'An unknown error occurred!'
            redirect "/host/#{params[:id]}"
          end
        end

        post '/:id/:action' do
          authorize!
          content_type :json

          begin
            action = params[:action]
            id = params[:id]
            host = Obscured::AptWatcher::Models::Host.find(id) rescue redirect('/')

            case action
              when 'connected' then host.set_state(Obscured::State::CONNECTED)
              when 'disconnected' then host.set_state(Obscured::State::DISCONNECTED)
              when 'decommissioned' then host.set_state(Obscured::State::DECOMMISSIONED)
              when 'failing' then host.set_state(Obscured::State::FAILING)
              when 'paused' then host.set_state(Obscured::State::PAUSED)
              when 'pending' then host.set_state(Obscured::State::PENDING)
              when 'ignored' then host.set_state(Obscured::State::IGNORED)
              when 'unknown' then host.set_state(Obscured::State::UNKNOWN)
              else nil
            end
            host.save

            Obscured::AptWatcher::Entities::Ajax::Response.new({:action => action, :state => host.state}).to_json
          rescue Exception => e
            Obscured::AptWatcher::Entities::Ajax::Error.new(e.message, e.class.name, false).to_json
          end
        end
      end
    end
  end
end
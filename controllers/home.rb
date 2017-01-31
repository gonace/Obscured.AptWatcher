module Obscured
  module AptWatcher
    module Controllers
      class Home < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/home'


        get '/home' do
          redirect '/'
        end

        get '/' do
          authenticated?

          alerts = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN).order_by(created_at: :desc).limit(10)
          alerts_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN).count
          alerts_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED).count

          scans = Obscured::AptWatcher::Models::Scan.all.order_by(created_at: :desc).limit(10)
          scans_total = Obscured::AptWatcher::Models::Scan.count

          hosts = Obscured::AptWatcher::Models::Host.all.order_by(updates_pending: :desc).limit(10)
          hosts_with_updates = Obscured::AptWatcher::Models::Host.where(:updates_pending.gt => 0).count
          hosts_without_updates = Obscured::AptWatcher::Models::Host.where(:updates_pending => 0).count

          graph_alerts = {}
          graph_updates = {}
          graph_scans = {}
          today = Date.today
          (today - 7.days .. today).each do |date|
            count = 0
            scan = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day)

            unless scan.first.nil?
              count = scan.first.updates_pending
            end

            (graph_updates['header'] ||= []) << date.strftime('%a %d')
            (graph_updates['data'] ||= []) << count

            a_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count
            a_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count
            (graph_alerts['header'] ||= []) << date.strftime('%a %d')
            (graph_alerts['data'] ||= [[],[]]).first << a_open
            (graph_alerts['data'] ||= [[],[]]).last << a_closed


            (graph_scans['header'] ||= []) << date.strftime('%a %d')
            (graph_scans['data'] ||= []) << scan.count
          end

          haml :index, :locals => { :alerts => alerts,
                                    :alerts_open => alerts_open,
                                    :alerts_closed => alerts_closed,
                                    :hosts => hosts,
                                    :hosts_with_updates => hosts_with_updates,
                                    :hosts_without_updates => hosts_without_updates,
                                    :scans => scans,
                                    :scans_total => scans_total,
                                    :graph_alerts => graph_alerts,
                                    :graph_scans => graph_scans,
                                    :graph_updates => graph_updates }
        end
      end
    end
  end
end
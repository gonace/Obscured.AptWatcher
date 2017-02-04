module Obscured
  module AptWatcher
    module Controllers
      class Statistics < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/statistics'


        get '/' do
          authorize!

          today = Date.today
          alerts_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          alerts_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED, :created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          errors_open = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::OPEN, :created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          errors_closed = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::CLOSED, :created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          hosts_active = 0
          Obscured::AptWatcher::Models::Host.all.each {|host| hosts_active = Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => today.beginning_of_day, :created_at.lte => today.end_of_day).distinct('hostname').count rescue 0}
          hosts_inactive = 0
          Obscured::AptWatcher::Models::Host.all.each {|host| (Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => today.beginning_of_day, :created_at.lte => today.end_of_day).distinct('hostname').count == 0) ? hosts_inactive += 1 : 0}

          count_alerts = Obscured::AptWatcher::Models::Alert.where(:created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          count_errors = Obscured::AptWatcher::Models::Error.where(:created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          count_hosts = Obscured::AptWatcher::Models::Host.where(:created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count
          count_scans = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => (today - 7.days).beginning_of_day, :created_at.lte => today.end_of_day).count

          graph_alerts = {}
          graph_updates = {}
          graph_scans = {}
          (today - 7.days .. today).each do |date|
            scan = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day)
            a_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count
            a_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count


            (graph_updates['header'] ||= []) << date.strftime('%a %d')
            (graph_updates['data'] ||= []) << Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).distinct('packages.name').count rescue 0
            (graph_alerts['header'] ||= []) << date.strftime('%a %d')
            (graph_alerts['data'] ||= [[],[]]).first << a_open
            (graph_alerts['data'] ||= [[],[]]).last << a_closed
            (graph_scans['header'] ||= []) << date.strftime('%a %d')
            (graph_scans['data'] ||= []) << scan.count
          end

          haml :index, :locals => { :alerts_open => alerts_open,
                                    :alerts_closed => alerts_closed,
                                    :count_alerts => count_alerts,
                                    :count_errors => count_errors,
                                    :count_hosts => count_hosts,
                                    :count_scans => count_scans,
                                    :errors_open => errors_open,
                                    :errors_closed => errors_closed,
                                    :graph_alerts => graph_alerts,
                                    :graph_updates => graph_updates,
                                    :graph_scans => graph_scans,
                                    :hosts_active => hosts_active,
                                    :hosts_inactive => hosts_inactive }
        end

        get '/monthly' do
          authorize!

          today = Date.today
          alerts_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          alerts_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED, :created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          errors_open = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::OPEN, :created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          errors_closed = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::CLOSED, :created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          hosts_active = 0
          Obscured::AptWatcher::Models::Host.all.each {|host| hosts_active = Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).distinct('hostname').count rescue 0}
          hosts_inactive = 0
          Obscured::AptWatcher::Models::Host.all.each {|host| (Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).distinct('hostname').count == 0) ? hosts_inactive += 1 : 0}

          count_alerts = Obscured::AptWatcher::Models::Alert.where(:created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          count_errors = Obscured::AptWatcher::Models::Error.where(:created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          count_hosts = Obscured::AptWatcher::Models::Host.where(:created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count
          count_scans = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => today.beginning_of_month, :created_at.lte => today.end_of_month).count


          graph_alerts = {}
          graph_updates = {}
          graph_scans = {}
          (today.beginning_of_month .. today.end_of_month).each do |date|
            scan = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day)
            a_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count
            a_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED, :created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).count


            (graph_updates['header'] ||= []) << date.strftime('%d')
            (graph_updates['data'] ||= []) << Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date.beginning_of_day, :created_at.lte => date.end_of_day).distinct('packages.name').count rescue 0
            (graph_alerts['header'] ||= []) << date.strftime('%d')
            (graph_alerts['data'] ||= [[],[]]).first << a_open
            (graph_alerts['data'] ||= [[],[]]).last << a_closed
            (graph_scans['header'] ||= []) << date.strftime('%d')
            (graph_scans['data'] ||= []) << scan.count
          end

          haml :monthly, :locals => { :alerts_open => alerts_open,
                                      :alerts_closed => alerts_closed,
                                      :count_alerts => count_alerts,
                                      :count_errors => count_errors,
                                      :count_hosts => count_hosts,
                                      :count_scans => count_scans,
                                      :errors_open => errors_open,
                                      :errors_closed => errors_closed,
                                      :graph_alerts => graph_alerts,
                                      :graph_updates => graph_updates,
                                      :graph_scans => graph_scans,
                                      :hosts_active => hosts_active,
                                      :hosts_inactive => hosts_inactive }
        end

        get '/yearly' do
          authorize!

          today = Date.today
          alerts_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          alerts_closed = Obscured::AptWatcher::Models::Alert.where(:status => :closed, :created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          errors_open = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::OPEN, :created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          errors_closed = Obscured::AptWatcher::Models::Error.where(:status => Obscured::Status::CLOSED, :created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          hosts_active = 0
          Obscured::AptWatcher::Models::Host.all.each {|host| hosts_active = Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).distinct('hostname').count rescue 0}
          hosts_inactive = 0
          Obscured::AptWatcher::Models::Host.all.each {|host| (Obscured::AptWatcher::Models::Scan.where(:hostname => host.hostname, :created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).distinct('hostname').count == 0) ? hosts_inactive += 1 : 0}

          count_alerts = Obscured::AptWatcher::Models::Alert.where(:created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          count_errors = Obscured::AptWatcher::Models::Error.where(:created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          count_hosts = Obscured::AptWatcher::Models::Host.where(:created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count
          count_scans = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => today.beginning_of_year, :created_at.lte => today.end_of_year).count


          graph_alerts = {}
          graph_updates = {}
          graph_scans = {}
          (1..12).to_a.each do |month_offset|
            date_start = DateTime.new(Date.today.year, month_offset, 1).beginning_of_month
            date_end = date_start.end_of_month

            scan = Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date_start, :created_at.lte => date_end)
            a_open = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::OPEN, :created_at.gte => date_start, :created_at.lte => date_end).count
            a_closed = Obscured::AptWatcher::Models::Alert.where(:status => Obscured::Status::CLOSED, :created_at.gte => date_start, :created_at.lte => date_end).count

            (graph_updates['header'] ||= []) << Date::MONTHNAMES[month_offset]
            (graph_updates['data'] ||= []) << Obscured::AptWatcher::Models::Scan.where(:created_at.gte => date_start, :created_at.lte => date_end).distinct('packages.name').count rescue 0
            (graph_alerts['header'] ||= []) << Date::MONTHNAMES[month_offset]
            (graph_alerts['data'] ||= [[],[]]).first << a_open
            (graph_alerts['data'] ||= [[],[]]).last << a_closed
            (graph_scans['header'] ||= []) << Date::MONTHNAMES[month_offset]
            (graph_scans['data'] ||= []) << scan.count
          end

          haml :yearly, :locals => { :alerts_open => alerts_open,
                                     :alerts_closed => alerts_closed,
                                     :count_alerts => count_alerts,
                                     :count_errors => count_errors,
                                     :count_hosts => count_hosts,
                                     :count_scans => count_scans,
                                     :errors_open => errors_open,
                                     :errors_closed => errors_closed,
                                     :graph_alerts => graph_alerts,
                                     :graph_updates => graph_updates,
                                     :graph_scans => graph_scans,
                                     :hosts_active => hosts_active,
                                     :hosts_inactive => hosts_inactive }
        end
      end
    end
  end
end
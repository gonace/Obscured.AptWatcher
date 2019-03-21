module Obscured
  module AptWatcher
    module Package
      class Matcher
        class << self
          def run(hostname, date_start=Date.yesterday, date_end=Date.today)
            date_start = Date.strptime(date_start, '%Y-%m-%d')
            date_end = Date.strptime(date_end, '%Y-%m-%d')
            first_scan = Obscured::AptWatcher::Models::Scan.where(:hostname => hostname, :created_at.gte => date_start.beginning_of_day, :created_at.lte => date_start.end_of_day).first
            second_scan = Obscured::AptWatcher::Models::Scan.where(:hostname => hostname, :created_at.gte => date_end.beginning_of_day, :created_at.lte => date_end.end_of_day).first

            if first_scan.nil? && second_scan.nil?
              Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SCAN, :message => 'No scan could be found, this might not be an error if this is the first time the host is checked'})
            else
              if defined? first_scan.packages
                first_scan.packages.each do |package|
                  if second_scan.packages.include?(package)
                    package['installed'] = false
                  else
                    package['installed'] = true
                  end
                end
                first_scan.set_updates_pending({:packages => first_scan.packages})
                first_scan.set_updates_installed({:packages => first_scan.packages})
                first_scan.save!

                first_scan
              else
                Obscured::AptWatcher::Models::Error.make!({:notifier => Obscured::Alert::Type::SCAN, :message => 'Scan does not contain a definition of :packages, this might not be an error if this is the first time the host is checked'})
              end
            end
          end
        end
      end
    end
  end
end
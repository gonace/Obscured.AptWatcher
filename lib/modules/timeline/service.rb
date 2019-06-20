module Mongoid
  module Timeline
    module Service
      module Base
        def self.included(base)
          base.extend ClassMethods
        end

        def all(criterion = nil)
          Record.with(collection: "#{self.class.name.demodulize.downcase}_timeline") do |m|
            m.all(criterion).to_a
          end
        end

        def find(*args)
          Record.with(collection: "#{self.class.name.demodulize.downcase}_timeline") do |m|
            m.find(*args)
          end
        end

        def find_by(attrs = {})
          Record.with(collection: "#{self.class.name.demodulize.downcase}_timeline") do |m|
            m.find_by(attrs).to_a
          end
        end

        def where(expression)
          Record.with(collection: "#{self.class.name.demodulize.downcase}_timeline") do |m|
            m.where(expression).to_a
          end
        end

        def by(params = {}, options = {})
          Record.with(collection: "#{self.class.name.demodulize.downcase}_timeline") do |m|
            m.by(params, options)
          end
        end

        def delete(id)
          Record.with(collection: "#{self.class.name.demodulize.downcase}_timeline") do |m|
            m.where(id: id.to_s).delete
          end
        end


        private

        class Record
          include Mongoid::Timeline::Record
        end
      end
    end
  end
end
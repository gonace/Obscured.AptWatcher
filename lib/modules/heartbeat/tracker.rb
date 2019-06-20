require 'active_support/concern'

module Mongoid
  module Heartbeat
    module Tracker
      extend ActiveSupport::Concern

      class Record
        include Mongoid::Heartbeat::Record
      end


      # Adds event to the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Add event.
      #   document.add_heartbeat
      #
      # @return [ document ]
      def add_heartbeat(event)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.make!(event.merge({:proprietor => { "#{self.class.name.demodulize.downcase}_id".to_sym => self.id.to_s }}))
        end
      end

      # Get an event from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get event.
      #   document.get_heartbeat(id)
      #
      # @return [ document ]
      def get_heartbeat(id)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.find(id)
        end
      end

      # Get events from the x_heartbeat collection for document by proprietor. This is
      # only called on manually.
      #
      # @example Get event.
      #   document.get_heartbeats
      #
      # @return [ documents ]
      def get_heartbeats
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.by({:proprietor => { "#{self.class.name.demodulize.downcase}_id".to_sym => self.id.to_s }})
        end
      end

      # Find events from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get event.
      #   document.find_heartbeats(params, options)
      #
      # @return [ documents ]
      def find_heartbeats(params, options)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.by({:proprietor => { "#{self.class.name.demodulize.downcase}_id".to_sym => self.id.to_s }}.merge(params), options)
        end
      end

      # Search events from the x_heartbeat collection for document. This is
      # only called on manually.
      #
      # @example Get event.
      #   document.search_heartbeats(text, options)
      #
      # @return [ documents ]
      def search_heartbeats(text, options)
        limit = options[:limit].blank? ? nil : options[:limit].to_i
        skip = options[:skip].blank? ? nil : options[:skip].to_i
        order = options[:order].blank? ? :created_at.desc : options[:order]

        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          query = {}
          query[:type] = options[:type].to_sym if options[:type]

          criteria = m.where(query).full_text_search(text)
          criteria = criteria.order_by(order) if order
          criteria = criteria.limit(limit).skip(skip)

          docs = criteria.to_a
          docs.map(&:to_hash)
        end
      end

      # Edit an event from the x_heartbeat collection by id. This is
      # only called on manually.
      #
      # @example Get event.
      #   document.edit_heartbeat(id, params)
      #
      # @return [ document ]
      def edit_heartbeat(id, params = {})
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          event = m.where(id: id).first
          event.message = params[:message] if params[:message]
          event.save
          event
        end
      end

      # Delete an event from the x_heartbeat collection by id. This is
      # only called on manually.
      #
      # @example Get event.
      #   document.delete_heartbeat(id)
      #
      # @return [ document ]
      def delete_heartbeat(id)
        Record.with(collection: "#{self.class.name.demodulize.downcase}_heartbeat") do |m|
          m.where(id: id).delete
        end
      end
    end
  end
end
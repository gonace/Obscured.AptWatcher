require 'mongoid'

module Mongoid
  module Heartbeat
    module Record
      extend ActiveSupport::Concern

      included do
        include Mongoid::Document
        include Mongoid::Search
        include Mongoid::Timestamps

        field :type, type: Symbol
        field :message, type: String
        field :producer, type: String
        field :proprietor, type: Hash

        index({ type: 1 }, background: true)
        index({ producer: 1 }, background: true)
        index({ _keywords: 1 }, background: true)

        search_in :id, :type, :producer
      end

      module ClassMethods
        def make(params = {})
          raise ArgumentError, 'type missing' if params[:type].blank?
          raise ArgumentError, 'type must be a symbol' unless params[:type].instance_of?(Symbol)
          raise ArgumentError, 'message missing' if params[:message].nil?
          raise ArgumentError, 'producer missing' if params[:producer].blank?
          raise ArgumentError, 'proprietor missing' if params[:proprietor].blank?

          doc = self.new
          doc.type = params[:type]
          doc.message = params[:message]
          doc.producer = params[:producer]
          doc.proprietor = params[:proprietor]
          doc
        end
        def make!(params = {})
          doc = make(params)
          doc.save!
          doc
        end


        def by(params = {}, options = {})
          limit = options[:limit].blank? ? nil : options[:limit].to_i
          skip = options[:skip].blank? ? nil : options[:skip].to_i
          order = options[:order].blank? ? :created_at.desc : options[:order]
          only = options[:only].blank? ? [:id, :type, :message, :producer, :created_at, :updated_at, :proprietor] : options[:only]

          query = {}
          query[:type] = params[:type].to_sym if params[:type]
          query[:producer] = params[:producer].to_sym if params[:producer]
          params[:proprietor].map { |k, v| query.merge!("proprietor.#{k}" => v.to_s) } if params[:proprietor]

          criterion = where(query).only(only).limit(limit).skip(skip)
          criterion = criterion.order_by(order) if order

          docs = criterion.to_a
          docs
        end
      end
    end
  end
end
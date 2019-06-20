module Obscured
  module AptWatcher
    module Models
      class Tag
        include Mongoid::Document
        include Mongoid::Timestamps

        store_in collection: 'tags'

        field :name, type: String
        field :type, type: Symbol

        index({:name => 1}, {:background => true})
        index({:name => 1, :type => 1}, {:background => true})


        class << self
          def make(params)
            raise Obscured::DomainError.new(:invalid_parameter, :what => "name (#{params[:name].to_sym})") if params[:name].blank?
            raise Obscured::DomainError.new(:invalid_parameter, :what => "type (#{params[:type].to_sym})") if params[:type].blank?
            if Tag.where({ :name => params[:name], :type => params[:type].to_sym }).exists?
              raise Obscured::DomainError.new(:already_exists, what: "Tag already exists (name: #{params[:name]})")
            end

            tag = self.new
            tag.name = params[:name]
            tag.type = params[:type].to_sym
            tag
          end
          def make!(params)
            tag = make(params)
            tag.save
            tag
          end

          def upsert(params)
            if Tag.where(name: params[:name], type: params[:type].to_sym).exists?
              return Tag.find_by(name: params[:name], type: params[:type].to_sym)
            end

            tag = make(params)
            tag
          end
          def upsert!(params)
            tag = upsert(params)
            tag.save
            tag
          end
        end
      end
    end
  end
end
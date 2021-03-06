module Obscured
  module AptWatcher
    module Controllers
      class Users < Obscured::AptWatcher::Controllers::Base
        set :views, settings.root + '/../views/users'


        get '/' do
          authorize!

          users = Obscured::Doorman::User.all

          haml :index, :locals => { :users => users }
        end

        get '/me' do
          authorize!

          redirect "/users/#{current_user.id}/view"
        end

        get '/:id/view' do
          authorize!

          begin
            user = Obscured::Doorman::User.find(params[:id]) rescue redirect('/users')

            haml :user, :locals => { :user => user }
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:generic_error] = 'An unknown error occurred!'
            redirect '/users'
          end
        end

        get '/create' do
          authenticated?

          haml :create, :locals => { }
        end

        post '/create' do
          authorize!

          begin
            user_email,user_firstname,user_lastname = params.delete('user_email'), params.delete('user_firstname'), params.delete('user_lastname')
            password_new,password_verify = params.delete('password_new'), params.delete('password_verify')

            user = OpenStruct.new()
            user.username = user_email
            user.first_name = user_firstname
            user.last_name = user_lastname

            if user_email.empty?
              flash.now[:save_error] = 'We need an email address to create the user!'
              return haml :create, :locals => { :user => user }
            else
              unless Obscured::Doorman::User.get_by_username(user_email).nil?
                flash.now[:save_error] = 'The username/email does already exists please change e-mail address!'
                return haml :create, :locals => { :user => user }
              end
            end
            if password_new.empty? or password_verify.empty?
              flash.now[:save_error] = 'We need a password to create the user!'
              haml :create, :locals => { :user => user }
            else
              unless password_new == password_verify
                flash.now[:save_error] = "The password verification does not match the password you've entered!"
                return haml :create, :locals => { :user => user }
              end
            end

            user = Obscured::Doorman::User.make({:username => user_email, :password => password_new})
            unless user_firstname.empty? or user_lastname.empty?
              user.set_name(user_firstname, user_lastname)
            end
            user.save

            flash[:save_ok] = "We're glad to announce that we could successfully created the user (#{user.username})"
            redirect "/users/#{user.id}/view"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash.now[:save_error] = "We're sad to announce that we could not create the user for an unknown reason"
            return haml :create, :locals => { :user => user }
          end
        end

        post '/:id/basics/update' do
          authorize!

          begin
            raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?

            user_email,user_firstname,user_lastname = params.delete('user_email'), params.delete('user_firstname'), params.delete('user_lastname')
            user = Obscured::Doorman::User.find(params[:id]) rescue redirect('/')

            unless user_firstname.empty? and user_lastname.empty?
              user.set_name(user_firstname, user_lastname)
            end
            unless user_email.empty?
              unless user_email.to_s == user.username.to_s
                user.set_username user_email
              end
            end
            user.add_history_log('Updated user basic properties', current_user.username)
            user.save

            flash[:save_ok] = "We're glad to announce that we could successfully save the changes for (#{user.username})"
            redirect "/users/#{user.id}/view"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:save_error] = "We're sad to announce that we could not save the changes for (#{user.username})"
            redirect "/users/#{user.id}/view"
          end
        end

        post '/:id/password/update' do
          authorize!

          begin
            raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?

            password_new,password_verify = params.delete('password_new'), params.delete('password_verify')
            user = Obscured::Doorman::User.find(params[:id]) rescue redirect('/users')

            unless password_new.empty? and password_verify.empty?
              if password_new == password_verify
                user.set_password(password_new)
                user.add_history_log('Updated user password', current_user.username)
                user.save
                flash[:save_ok] = "We're glad to announce that we could successfully change the password for (#{user.username})"
              else
                flash[:save_error] = "Password doesn't match, please try again!"
              end
            else
              flash[:save_error] = 'You have to provide a password!'
            end
            redirect "/users/#{user.id}/view"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:save_error] = "We're sad to announce that we could not change password for (#{user.username})"
            redirect "/users/#{user.id}/view"
          end
        end

        post '/:id/permissions/update' do
          authorize!

          begin
            raise Obscured::DomainError.new(:required_field_missing, what: ':id') if params[:id].empty?


            role = params.delete('user_role')
            user = Obscured::Doorman::User.find(params[:id]) rescue redirect('/users')

            unless role.empty?
              user.set_role(role)
              user.save
              flash[:save_ok] = "We're glad to announce that we could successfully change the permission role for (#{user.username})"
            end

            redirect "/users/#{user.id}/view"
          rescue => e
            Obscured::AptWatcher::Models::Error.make_and_save({:notifier => Obscured::Alert::Type::SYSTEM, :message => e.message, :backtrace => e.backtrace.join('<br />')})
            Raygun.track_exception(e)

            flash[:save_error] = "We're sad to announce that we could not update permissions for (#{user.username})"
            redirect "/users/#{user.id}/view"
          end
        end
      end
    end
  end
end
module Obscured
  module Doorman
    module Helper
      # The main accessor to the warden middleware
      def warden
        request.env['warden']
      end

      # Check the current session is authenticated to a given scope
      def authenticated?
        warden.authenticated?
      end

      # Return session info
      #
      # @param [Symbol] scope the scope to retrieve session info for
      def session_info(scope=nil)
        scope ? warden.session(scope) : scope
      end

      # Access the user from the current session
      #
      # @param [Symbol] scope for the logged in user
      def user(scope=nil)
        scope ? warden.user(scope) : warden.user
      end
      alias_method :current_user, :user

      # Require authorization for an action
      #
      # @param [String] failure_path path to redirect to if user is unauthenticated
      def authorize!(failure_path=nil)
        unless authenticated?
          session[:return_to] = request.path if Obscured::Doorman.config.use_referrer
          redirect(failure_path ? failure_path : Obscured::Doorman.config.paths[:login])
        end
      end
    end
  end
end
require File.expand_path('../../../lib/redmine_cas.rb', __FILE__)

  module RedmineCas
    module AccountControllerPatch

      def original_login
        if request.post?
          authenticate_user
        else
          if User.current.logged?
            redirect_back_or_default home_url, :referer => true
          end
        end
      rescue AuthSourceException => e
        logger.error "An error occurred when authenticating #{params[:username]}: #{e.message}"
        render_error :message => e.message
      end

      def login
        if (RedmineCas.enabled?)
          if RedmineCas.hide_local_login?
            return redirect_to(:controller => "account", :action => "cas")
          else
            Rails.logger.info "CAS activé et  local login cacaahé" #original_login
            original_login
          end
        else
          original_login
        end
      end

      def logout_with_cas
        return logout_without_cas unless RedmineCas.enabled?
        logout_user
        CASClient::Frameworks::Rails::Filter.logout(self, home_url)
      end

      def cas
        return redirect_to_action('login') unless RedmineCas.enabled?

        if User.current.logged?
          # User already logged in.
          redirect_to_ref_or_default
          return
        end

        if CASClient::Frameworks::Rails::Filter.filter(self)
          user = User.find_by_login(session[:cas_user])

          # Auto-create user if possible
          if user.nil? && RedmineCas.autocreate_users?
            user = User.new
            user.login = session[:cas_user]
            user.assign_attributes(RedmineCas.user_extra_attributes_from_session(session))
            return cas_user_not_created(user) if !user.save
            user.reload
          end

          return cas_user_not_found if user.nil?
          return cas_account_pending unless user.active?

          user.update_attribute(:last_login_on, Time.now)
	        user.update(RedmineCas.user_extra_attributes_from_session(session))
          if RedmineCas.single_sign_out_enabled?
            # logged_user= would start a new session and break single sign-out
            User.current = user
            start_user_session(user)
          else
            self.logged_user = user
          end

          redirect_to_ref_or_default
        end
      end

      def redirect_to_ref_or_default
	
	     #default_url = url_for(params.to_unsafe_h.merge(:ticket => nil))
	      default_url = home_url
	      #default_url = url_for(params.to_unsafe_h)
        if params.has_key?(:ref)
          # do some basic validation on ref, to prevent a malicious link to redirect
          # to another site.
          new_url = params[:ref]
          if /http(s)?:\/\/|@/ =~ new_url
            # evil referrer!
            redirect_to default_url
          else
            redirect_to request.base_url + params[:ref]
          end
        else
          redirect_to default_url
        end
      end

      def cas_account_pending
        render_403 :message => l(:notice_account_pending)
      end

      def cas_user_not_found
        render_403 :message => l(:redmine_cas_user_not_found, :user => session[:cas_user])
      end

      def cas_user_not_created(user)
        logger.error "Could not auto-create user: #{user.errors.full_messages.to_sentence}"
        render_403 :message => l(:redmine_cas_user_not_created, :user => session[:cas_user])
      end

    end
  end

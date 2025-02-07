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

       uri = URI(params['back_url'])
       return redirect_to(:controller => "account", :action => "cas", :ref => uri.path  )
          else
          original_login
        end
      else
        original_login
      end
    end
    # Log out current user and redirect to welcome page
    def logout
      if RedmineCas.enabled?
          logout_user
        logout_with_cas
      else

        if User.current.anonymous?
          redirect_to home_url
        elsif request.post?
          logout_user
          redirect_to home_url
        end
        # display the logout form
      end
    end

    def logout_with_cas
      Rails.logger.info "Logout with CAS"
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

      my_dest=nil
      my_dest=params[:ref] unless !params.include?(:ref)

      if my_dest.nil?
        my_url="#{home_url}/#{action_name}?ref=/"
      else
        my_url="#{home_url}/#{action_name}?ref="+params[:ref]
      end

      CASClient::Frameworks::Rails::Filter.configure(
        :service_url => my_url,
        :cas_base_url => Setting.plugin_redmine_cas['cas_url'],
        :logger => Rails.logger,
        :enable_single_sign_out => RedmineCas.single_sign_out_enabled?
      )

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
      default_url = home_url
      
      if params.has_key?(:ref)
        # do some basic validation on ref, to prevent a malicious link to redirect
        # to another site.
        new_url = params[:ref]
        if /http(s)?:\/\/|@/ =~ new_url
          # evil referrer!
          redirect_to default_url
	  Rails.logger.info "Redirect to default uRL"
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

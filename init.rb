require 'redmine'
require File.expand_path('../lib/redmine_cas.rb', __FILE__)
require File.expand_path('../lib/redmine_cas/application_controller_patch', __FILE__)
require File.expand_path('../lib/redmine_cas/account_controller_patch.rb', __FILE__)
require File.expand_path('../lib/redmine_cas_hook_listener', __FILE__)

Redmine::Plugin.register :redmine_cas do
  name 'Redmine CAS'
  author 'Jérôme GALLOT (Original author : Nils Caspar (Nine Internet Solutions AG)'
  description 'Plugin to CASify your Redmine installation.'
  version '1.3.0'
  url 'https://github.com/JGallot/redmine_cas'
  author_url 'https://github.com/JGallot'

  settings :default => {
    'enabled' => false,
    'cas_url' => 'https://',
    'attributes_mapping' => 'firstname=first_name&lastname=last_name&mail=email',
    'autocreate_users' => false,
    'hide_local_login' => false,
    'cas_button_text'  => 'Connect via CAS',
    'cas_between_text' => 'Or identify via local account'

  }, :partial => 'redmine_cas/settings'

  ApplicationController.prepend(RedmineCas::ApplicationControllerPatch)
  AccountController.prepend(RedmineCas::AccountControllerPatch)

  ActionDispatch::Callbacks.before do
    RedmineCas.setup!
  end

end

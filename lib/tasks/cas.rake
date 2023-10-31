
namespace :redmine do
  namespace :plugins do
    namespace :redmine_cas do

      desc "Redmine CAS : Show current settings"
      task :settings => :environment do
        puts Setting.plugin_redmine_cas
      end
      desc "Update Redmine CAS Settings : Enable hiding of local login"
      task :hide_local_login => :environment do
        Setting.plugin_redmine_cas['hide_local_login']='1'
        Setting.where(:name => 'plugin_redmine_cas').update(:value=>Setting.plugin_redmine_cas.with_indifferent_access)
      end
      desc "Update Redmine CAS Settings : Show local login"
      task :show_local_login => :environment do
        Setting.plugin_redmine_cas.delete('hide_local_login')
        Setting.where(:name => 'plugin_redmine_cas').update(:value=>Setting.plugin_redmine_cas.with_indifferent_access)
      end
      desc "Update Redmine CAS Settings : Enable plugin"
      task :enable => :environment do
        Setting.plugin_redmine_cas['enabled']='1'
        Setting.where(:name => 'plugin_redmine_cas').update(:value=>Setting.plugin_redmine_cas.with_indifferent_access)
      end
      desc "Update Redmine CAS Settings : Disable plugin"
      task :disable => :environment do
        Setting.plugin_redmine_cas.delete('enabled')
        Setting.where(:name => 'plugin_redmine_cas').update(:value=>Setting.plugin_redmine_cas.with_indifferent_access)
      end
    end
  end
end


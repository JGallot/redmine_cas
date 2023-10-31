# Redmine CAS plugin

Plugin to CASify your Redmine installation.

## Compatibility

Tested with Redmine 5.0.X
Tested with no public Area
BEWARE : Attributes assignation not tested (correction for Rails 6.1 done) nor auto create users were used

## Installation

1. Download or clone this repository and place it in the Redmine `plugins` directory as `redmine_cas`
2. Restart your webserver
3. Open Redmine and check if the plugin is visible under Administration > Plugins
4. Follow the "Configure" link and set the parameters
5. Party

## Notes

Beware ruby casclient is a bit too old

### Usage

If your installation has no public areas ("Authentication required") and you are not logged in, you will be
redirected to the CAS-login page.  The default login page will still work when you access it directly 
(http://example.com/path-to-redmine/login).

If your installation is not "Authentication required", the login page will show a link that lets you login
with CAS.

### Single Sign Out, Single Logout

No Single Sign OUt -> close your navivgator or clear your cookies

The sessions have to be stored in the database to make Single Sign Out work.
Old tip : You can achieve this with a tiny plugin: [redmine_activerecord_session_store](https://github.com/pencil/redmine_activerecord_session_store)

### Auto-create users

By enabling this setting, successfully authenticated users will be automatically added into Redmine if they do not already exist. You *must* define the attribute mapping for at least firstname, lastname and mail attributes for this to work.

### Rake tasks
If some configuration is buggy, you can change some settings in command-line

####
* Hide login/password input fields
<code>RAILS_ENV=production bundle exec rake redmine:plugins:redmine_cas:hide_local_login</code>

* Show Login/password input fields
<code>RAILS_ENV=production bundle exec rake redmine:plugins:redmine_cas:show_local_login</code>

* Enable plugin
<code>RAILS_ENV=production bundle exec rake redmine:plugins:redmine_cas:enable</code>

* Disable plugin

<code>RAILS_ENV=production bundle exec rake redmine:plugins:redmine_cas:enable</code>
## Copyright

Copyright (c) 2023 Jérôme GALLOT EI

Copyright (c) 2013-2014 Nine Internet Solutions AG. See LICENSE.txt for further details.

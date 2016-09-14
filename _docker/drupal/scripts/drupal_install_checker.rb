require 'open3'
require 'fileutils'
require 'yaml'

class ProcessExecutor
  def exec!(cmd, args = [])
    puts "DEBUG - executing command #{cmd} #{args}"
    out, status = Open3.capture2e(cmd, *args)
    raise out if status.exitstatus != 0
    out
  end
end

class DrupalInstallChecker
  attr_reader :drupal_site, :process_executor

  def initialize(drupal_site, process_executor = ProcessExecutor.new, opts)
    @drupal_site = drupal_site
    @process_executor = process_executor
    @opts = opts
  end

  def settings_exists?
    File.exists? File.join drupal_site, 'settings.php'
  end

  def rhd_settings_exists?
    File.exists? File.join drupal_site, 'rhd.settings.php'
  end

  def mysql_connect?
    begin
      process_executor.exec! 'mysql', ["--host=#{@opts['database']['host']}",
                                       "--port=#{@opts['database']['port']}",
                                       "--user=#{@opts['database']['username']}",
                                       "--password=#{@opts['database']['password']}",
                                       '--connect-timeout=20',
                                       "#{@opts['database']['name']}"]
      true
    rescue => e
      puts "ERROR: #{e.message}"
      false
    end
  end

  def tables_exists?
    begin
      tables_to_check = %w(node comment node__body taxonomy_index)
      tables = process_executor.exec!('mysql', ["--host=#{@opts['database']['host']}",
                                                "--port=#{@opts['database']['port']}",
                                                "--user=#{@opts['database']['username']}",
                                                "--password=#{@opts['database']['password']}",
                                                '--execute=show tables', "#{@opts['database']['name']}"]).split("\n")[1..-1]
      return false if tables.nil? || tables.empty?
      (tables_to_check.uniq.sort - tables.uniq.sort).empty?
    rescue => e
      puts "ERROR: #{e.message}"
      false
    end
  end

  #
  # This works-around a bug in the workspace module install in staging and production environments. We need to set the
  # initial id of the row inserted into the workspace table to 1 from 9. In environments where this does not occur e.g
  # drupal-dev, drupal-pull-request, this method is essentially a null-op
  #
  def workaround_workspace_bug
    process_executor.exec!('mysql', ["--host=#{@opts['database']['host']}",
                                     "--port=#{@opts['database']['port']}",
                                     "--user=#{@opts['database']['username']}",
                                     "--password=#{@opts['database']['password']}",
                                     '--execute=update workspace set id=1 where id=9', "#{@opts['database']['name']}"])
  end

  def installed?
    settings_exists? && rhd_settings_exists? && mysql_connect? && tables_exists?
  end

  #
  # Installs custom configuration for anything 3rd party module that is installed.
  #
  def install_module_configuration
    %w(simple_sitemap).each do | module_name |
      puts "Installing settings for module #{module_name}..."
      process_executor.exec!('/var/www/drupal/vendor/bin/drupal', ['--root=web','config:import:single',"#{module_name}.settings","/var/www/drupal/config/#{module_name}.settings"])
    end
  end

  def install_theme
    puts 'Installing Drupal theme...'
    process_executor.exec!('/var/www/drupal/vendor/bin/drupal', %w(--root=web theme:install --set-default rhd))
  end

  def install_modules
    puts 'Installing Drupal modules...'
    module_install_args = ['--root=web', 'module:install', 'serialization', 'basic_auth', 'basewidget', 'rest',
                           'layoutmanager', 'hal', 'redhat_developers', 'syslog', 'diff', 'entity',
                           'entity_storage_migrate', 'key_value', 'multiversion', 'token', 'metatag',
                           'metatag_google_plus', 'metatag_open_graph', 'metatag_twitter_cards',
                           'metatag_verification', 'admin_toolbar', 'admin_toolbar_tools', 'simple_sitemap']

    if @opts['environment'] == 'dev'
      module_install_args.push(*%w(devel kint))
    end
    process_executor.exec!('/var/www/drupal/vendor/bin/drupal', module_install_args)
  end

  #
  # This sets the cron key to a known value for the Drupal instance so that we can invoke cron remotely
  #
  def set_cron_key
    puts 'Setting the cron key...'
    process_executor.exec!('/var/www/drupal/vendor/bin/drupal', %w(--root=web state:override system.cron_key rhd))
  end

  def install_drupal
    puts 'Installing Drupal, please wait...'
    process_executor.exec!('/var/www/drupal/vendor/bin/drupal',
                           ['--root=web', 'site:install', 'standard', '--langcode=en', '--db-type=mysql',
                            "--db-host=#{@opts['database']['host']}", "--db-name=#{@opts['database']['name']}",
                            "--db-user=#{@opts['database']['username']}", "--db-port=#{@opts['database']['port']}",
                            "--db-pass=#{@opts['database']['password']}", '--account-name=admin',
                            "--site-name='Red Hat Developers'", "--site-mail='test@example.com'",
                            "--account-mail='admin@example.com'", '--account-pass=admin', '-n'])
  end

  def update_db
    puts 'Executing drush dbup'
    process_executor.exec!('/var/www/drupal/vendor/bin/drupal', ['--root=/var/www/drupal/web', 'cache:rebuild', 'all'])
    process_executor.exec!('/var/www/drupal/vendor/bin/drush', ['-y','--root=/var/www/drupal/web', '--entity-updates', 'updb'])
  end

  def import_config
    process_executor.exec!('/var/www/drupal/vendor/bin/drush', ['--root=/var/www/drupal/web', '-y cim'])
    process_executor.exec!('/var/www/drupal/vendor/bin/drush', ['--root=/var/www/drupal/web', 'cr all'])
    process_executor.exec!('/var/www/drupal/vendor/bin/drupal', ['--root=/var/www/drupal/web', 'config:delete active field.storage.node.field_author_name'])
    process_executor.exec!('/var/www/drupal/vendor/bin/drush', ['--root=/var/www/drupal/web', '-y cim'])
    process_executor.exec!('/var/www/drupal/vendor/bin/drush', ['--root=/var/www/drupal/web', 'cr all'])
  end
end

if $0 == __FILE__
  drupal_site_dir = '/var/www/drupal/web/sites/default'
  opts = YAML.load_file(File.join(drupal_site_dir, 'rhd.settings.yml'))
  checker = DrupalInstallChecker.new(drupal_site_dir, ProcessExecutor.new, opts)

  mysql_up = false
  until mysql_up
    puts 'Waiting for mysql to boot up...'
    mysql_up = checker.mysql_connect?
  end

  if checker.installed?
    checker.import_config
    checker.update_db
  else
    checker.install_drupal
    checker.install_theme
    checker.install_modules
    checker.install_module_configuration
    checker.set_cron_key
    checker.import_config
    checker.workaround_workspace_bug
  end
end

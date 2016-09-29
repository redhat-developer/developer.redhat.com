<?php
use Symfony\Component\Yaml\Yaml;

if (file_exists(__DIR__ . '/rhd.settings.yml')) {
  $yml_settings = Yaml::parse(file_get_contents(__DIR__ . "/rhd.settings.yml")); 
  $config['redhat_developers'] = $yml_settings;
}

$config['automated_cron.settings']['interval'] = 0;
$settings['hash_salt'] = 'xuAWpK0fmrZ6UGofFcP3lBkcmdpdumWMLqvCbnYjFY85OgRXYvEKPItJDH66vs4UpeYORQXLHQ';
$settings['install_profile'] = 'standard';
$config_directories['sync'] = 'sites/default/files/config_BbPlfGDu86LJqlRwhA9RbCf38VZMDijNF-owvfhuzVL73hk7BtWwy3kfIlqKLXeiSgTA-MHeVw/sync';

$databases['default']['default'] = array (
  'database' => 'drupal',
  'username' => 'drupal',
  'password' => 'drupal',
  'prefix' => '',
  'host' => 'drupalmysql',
  'port' => '3306',
  'namespace' => 'Drupal\\Core\\Database\\Driver\\mysql',
  'driver' => 'mysql',
);


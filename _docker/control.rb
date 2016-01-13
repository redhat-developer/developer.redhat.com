#!/usr/bin/env ruby

require 'optparse'
require 'fileutils'
require 'tempfile'
require 'gpgme'
require 'yaml'
require 'docker'
require 'socket'
require 'timeout'
require 'erb'
require 'resolv'
require 'open3'
require './lib/options.rb'
require './lib/file_helpers.rb'

def modify_env
  begin
    puts 'decrypting vault'
    crypto = GPGME::Crypto.new
    fname = File.open '../_config/secrets.yaml.gpg'

    secrets = YAML.load(crypto.decrypt(fname).to_s)

    secrets.each do |k, v|
      ENV[k] = v
    end
    puts 'Vault decrypted'
  rescue GPGME::Error => e
    abort "Unable to decrypt vault (#{e})"
  end
end

def set_ports

  #The environment names here are for INTERNAL purposes only and do not relate to
  #variables generated by docker or docker-compose
  port_names = ['AWESTRUCT_HOST_PORT', 'DRUPAL_HOST_PORT', 'DRUPALPGSQL_HOST_PORT',
    'MYSQL_HOST_PORT', 'SEARCHISKO_HOST_PORT']

  #We only set ports for ENVs not already set.
  ports_to_set = port_names.select{ |x| ENV[x].to_s == '' }

  # We have to reverse the logic in `is_port_open` because if nothing is listening, we can use it
  available_ports = (32768..61000).lazy.select {|port| !is_port_open?('docker', port)}.take(ports_to_set.size).force
  ports_to_set.each_with_index do |name, index|
    puts "#{name} available at #{available_ports[index]}"
    ENV[name] = available_ports[index].to_s
  end
end

def execute_docker_compose(cmd, args = [])
  puts "args to docker compose are #{args}"
  Kernel.abort('Error running docker-compose') unless Kernel.system *['docker-compose', cmd.to_s, *args]
end

def execute_docker(cmd, *args)
  Kernel.abort('Error running docker') unless Kernel.system 'docker', cmd.to_s, *args
end

def is_port_open?(host, port)
  begin
    Timeout::timeout(1) do
      begin
        s = TCPSocket.new(Resolv.new.getaddress(host), port)
        s.close
        true
      rescue Errno::ECONNREFUSED, Errno::EHOSTUNREACH
        # Doesn't matter, just means it's still down
        false
      end
    end
  rescue Timeout::Error
    # We don't really care about this
    false
  end
end

def block_wait_drupal_started
  docker_drupal = Docker::Container.all(filters: {label: ['com.docker.compose.service=drupal']}.to_json).first
  until docker_drupal.json['NetworkSettings']['Ports']
    sleep(5)
    docker_drupal = Docker::Container.get("#{project_name}_drupal_1")
  end

  # Check to see if Drupal is accepting connections before continuing
  puts 'Waiting to proceed until Drupal is up'
  drupal_port80_info = docker_drupal.json['NetworkSettings']['Ports']['80/tcp'].first
  drupal_ip = "docker"
  drupal_port = drupal_port80_info['HostPort']

  # Add this to the ENV so we can pass it to the awestruct build
  ENV['DRUPAL_HOST_IP'] = drupal_ip

  up = false
  until up do
    up = is_port_open?(drupal_ip, drupal_port)
  end
end

private def project_name
  if ENV['COMPOSE_PROJECT_NAME'].to_s == ''
    "docker"
  else
    ENV['COMPOSE_PROJECT_NAME']
  end
end

def block_wait_searchisko_configure_finished
  begin
    configure_service = Docker::Container.get("#{project_name}_searchiskoconfigure_1")
  rescue Excon::Errors::SocketError => se
    puts se.backtrace
    puts('There has been a problem with your CA certs, are you developing using boot2docker?')
    puts('If so set your DOCKER_SSL_VERIFY environment variable to false')
    puts('E.g export DOCKER_SSL_VERIFY=false')
    exit #quit the whole thing
  end

  puts 'Waiting to proceed until searchiskoconfigure has completed'

  # searchiskoconfigure takes a while, we need to wait to proceed
  while configure_service.info['State']['Running']
    # TODO We need to figure out if the container has actually died, if it died print an error and abort
    sleep 5
    configure_service = Docker::Container.get("#{project_name}_searchiskoconfigure_1")
  end
end

tasks = Options.parse ARGV

if(tasks.empty?)
  puts Options.parse %w(-h)
end

#the docker url is taken from DOCKER_HOST env variable otherwise
Docker.url = tasks[:docker] if tasks[:docker]

if tasks[:decrypt]
  puts 'Decrypting...'
  modify_env
end

if tasks[:set_ports]
  puts 'Setting ports...'
  set_ports()
  # Output the new docker-compose file with the modified ports
  File.delete('docker-compose.yml') if File.exists?('docker-compose.yml')
  File.write('docker-compose.yml', ERB.new(File.read('docker-compose.yml.erb')).result)
end

if tasks[:kill_all]
  puts 'Killing docker services...'
  execute_docker_compose :stop
end

if tasks[:build]
  puts 'Building...'
  docker_dir = 'awestruct'

  parent_gemfile = File.open '../Gemfile'
  parent_gemlock = File.open '../Gemfile.lock'

  target_gemfile = FileHelpers.open_or_new(docker_dir + '/Gemfile')
  target_gemlock = FileHelpers.open_or_new(docker_dir + '/Gemfile.lock')
  #Only copy if the file has changed. Otherwise docker won't cache optimally
  FileHelpers.copy_if_changed(parent_gemfile, target_gemfile)
  FileHelpers.copy_if_changed(parent_gemlock, target_gemlock)

  puts 'Building base docker image...'
  execute_docker(:build, '--tag=developer.redhat.com/base', './base')
  puts 'Building base Java docker image...'
  execute_docker(:build, '--tag=developer.redhat.com/java', './java')
  puts 'Building base Ruby docker image...'
  execute_docker(:build, '--tag=developer.redhat.com/ruby', './ruby')
  puts 'Building services...'
  execute_docker_compose :build
end

if tasks[:unit_tests]
  puts "Running the unit tests"
  execute_docker_compose :run, tasks[:unit_tests]
end

if tasks[:should_start_supporting_services]
  puts 'Starting up services...'

  execute_docker_compose :up, ['--force-recreate'].concat(tasks[:supporting_services])

  if tasks[:supporting_services].include? "searchiskoconfigure"
    block_wait_searchisko_configure_finished()
  end

  # Check to see if Drupal is accepting connections before continuing
  block_wait_drupal_started if tasks[:drupal]
end

if tasks[:awestruct_command_args]
  puts 'running awestruct command'
  block_wait_drupal_started if tasks[:drupal]
  execute_docker_compose :run, tasks[:awestruct_command_args]
end

if tasks[:awestruct_up_service]
  puts 'bringing up awestruct service'
  execute_docker_compose :up, ['--force-recreate'].concat(tasks[:awestruct_up_service])
end

if tasks[:acceptance_test_target_task]
  puts 'running features task'
  execute_docker_compose :run, tasks[:acceptance_test_target_task]
end

require 'erb'
require 'fileutils'

#
# Models an environment supported by the developers.redhat.com start-up scripts.
#
# This implementation expects an environment to contain a docker-compose.yml file in the root of the directory
#
# @author rblake@redhat.com
#
class RhdEnvironment

  attr_accessor :environment_name, :environment_directory

  def initialize(environment_directory, testing_directory)
    @environment_directory = environment_directory
    @testing_directory = testing_directory
    @environment_name = environment_directory.split('/').last
  end

  #
  # This method gives the environment a chance to initialise anything that it might need. Typically this will be
  # setting/loading properties, but it can be anything
  #
  def initialize_environment
    if @environment_name == 'drupal-pull-request'
      pull_request_number = ENV['ghprbPullId']

      #
      # In a drupal PR environment, we take the pull request number and add it to 35000 to provide
      # a consistent port number for the Drupal instance throughout the life of the pull-request. The
      # 'DRUPAL_HOST_PORT' env variable is passed to the docker-compose commmand, which is used
      # as a template variable when setting the Drupal port that is exposed on the local machine.
      #
      unless pull_request_number.nil? || pull_request_number.empty?
        pr_drupal_port = 35000 + pull_request_number.to_i
        ENV['DRUPAL_HOST_PORT'] = pr_drupal_port.to_s
        puts "- Drupal port has been bound to '#{pr_drupal_port}'."
      end
    end
  end

  #
  # Before starting execution, should we check to pull the latest data image into this environment
  #
  def pull_drupal_data_image?
    @environment_name == 'drupal-dev' || @environment_name == 'drupal-pull-request'
  end

  #
  # Get the path to the docker-compose.yml file for this environment
  #
  def get_docker_compose_file
    "#{@environment_directory}/docker-compose.yml"
  end

  def get_testing_docker_compose_file
    "#{@testing_directory}/docker-compose.yml"
  end

  #
  # Is this an environment in which we run Drupal?
  #
  def is_drupal_environment?
    @environment_name.include?('drupal')
  end

  #
  # Performs cursory checks to determine if this looks like a valid environment directory
  #
  def is_valid_environment?
    has_docker_compose = File.exist?(get_docker_compose_file)

    if !has_docker_compose
      puts "Environment '#{environment_name}' defined in directory '#{@environment_directory}' is not valid as it does not contain a docker-compose.yml"
    end

    has_docker_compose
  end

  def create_file(file_name)
    absolute_file_path = get_absolute_file_name(file_name)

    FileUtils.rm(absolute_file_path, :force => true)
    FileUtils.touch(absolute_file_path)
    get_file(file_name)
  end

  def get_absolute_file_name(file_name)
    File.join @environment_directory, file_name
  end

  def get_file(file_name)
    get_absolute_file_name(file_name)
  end

  def create_template_resources
    if @environment_name == 'drupal-pull-request'
        create_file('rhd.settings.yml')
    end
  end

  #
  # Templates any resources required by the environment. In reality the only environment
  # that needs this is the Drupal pull-request environment
  #
  def template_resources
    if @environment_name == 'drupal-pull-request'
      output_file = get_file('rhd.settings.yml')
      File.write(output_file, ERB.new(File.read(get_file('rhd.settings.yml.erb'))).result)
    end
  end

  #
  # Returns the likely docker-compose project name for this environment. If the environment
  # variable ENV['COMPOSE_PROJECT_NAME'] is set, then this is used in preference.
  #
  def get_compose_project_name
    if ENV['COMPOSE_PROJECT_NAME'].to_s == ''
      @environment_name.gsub('-','')
    else
      ENV['COMPOSE_PROJECT_NAME']
    end
  end

  def get_proxy
    requires_proxy? ? 'proxy01.util.phx2.redhat.com:8080' : nil
  end

  def get_http_proxy
     get_proxy
  end

  def get_https_proxy
    get_proxy
  end

  def requires_proxy?
    @environment_name == 'drupal-staging' or @environment_name == 'drupal-production'
  end

  #
  # Provides the list of supporting services that should be started in each environment before
  # running Awestruct
  #
  def get_supporting_services

    supporting_services = []

    case @environment_name
      when 'awestruct-dev'
        supporting_services+= %w(mysql searchisko)
      when 'drupal-dev-local-dcp'
        supporting_services+= %w(apache mysql searchisko drupalmysql drupal)
      when 'drupal-dev'
        supporting_services+= %w(apache drupalmysql drupal)
      when 'drupal-pull-request'
         supporting_services+= %w(drupalmysql drupal)
      when 'drupal-staging', 'drupal-production'
        supporting_services += %w(drupal)
    end
    supporting_services

  end

  private :get_absolute_file_name, :get_proxy

end

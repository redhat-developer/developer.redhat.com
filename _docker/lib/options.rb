class Options

  def self.parse(args)
    tasks = {supporting_services: %w(-d)}

    opts_parse = OptionParser.new do |opts|
      opts.banner = 'Usage: control.rb [options]'
      opts.separator 'Specific options:'

      docker_message = "Docker client connection info (i.e. tcp://example.com:1000). "\
                       "DOCKER_HOST used if parameter not provided"
      opts.on('-d', '--docker CONNECTION_INFO', String, docker_message) do |d|
        tasks[:docker] = d
      end

      opts.on('-r', '--restart', 'Restart the containers') do |r|
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:kill_all] = true
        tasks[:supporting_services] += %w(mysql searchisko searchiskoconfigure)
      end

      opts.on('-t', '--unit-test', 'Run the unit tests') do |b|
        tasks[:unit_tests] = unit_test_tasks
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:build] = true
      end


      opts.on('-b', '--build', 'Build the containers') do |b|
        tasks[:decrypt] = true
        tasks[:unit_tests] = unit_test_tasks
        tasks[:set_ports] = true
        tasks[:build] = true
      end

      opts.on('-g', '--generate', 'Run awestruct (clean gen)') do |r|
        tasks[:decrypt] = true
        tasks[:awestruct_command_args] = ['--no-deps', '--rm', '--service-ports', 'awestruct', "rake git_setup clean gen[profile]"]
      end

      opts.on('-p', '--preview', 'Run awestruct (clean preview)') do |r|
        tasks[:decrypt] = true
        tasks[:awestruct_command_args] = ['--no-deps', '--rm', '--service-ports', 'awestruct', "rake git_setup clean preview[profile]"]
      end

      opts.on('--drupal-nightly', 'Start up and enable drupal') do |u|
        tasks[:drupal] = true
        tasks[:kill_all] = true
        tasks[:set_ports] = true
        tasks[:supporting_services] += %w(drupal drupalpgsql)
      end

      opts.on('-u', '--drupal', 'Start up and enable drupal') do |u|
        tasks[:decrypt] = true
        tasks[:drupal] = true
        tasks[:set_ports] = true
        tasks[:supporting_services] += %w(drupal drupalpgsql)
      end

      opts.on('--stage-pr PR_NUMBER', Integer, 'build for PR Staging') do |pr|
        tasks[:awestruct_command_args] = ["--no-deps", "--rm", "--service-ports", "awestruct", "bundle exec rake create_pr_dirs[docker-pr,build,#{pr}] clean deploy[staging_docker]"]
        tasks[:kill_all] = true
        tasks[:build] = true
        tasks[:unit_tests] = unit_test_tasks
        tasks[:set_ports] = true
        tasks[:supporting_services] += %w(mysql searchisko searchiskoconfigure)
      end

      opts.on('--acceptance_test_docker', String, 'runs the cucumber features against the local running docker stack.') do
        if ENV['RHD_SELENIUM_DRIVER'].to_s.empty?
          ENV['RHD_SELENIUM_DRIVER']='firefox'
        end

        if ENV['PARALLEL_TEST'].to_s.empty?
          ENV['PARALLEL_TEST']='true'
        end

        tasks[:kill_all] = true
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:build] = true
        tasks[:unit_tests] = unit_test_tasks
        tasks[:supporting_services] += %w(mysql searchisko searchiskoconfigure)
        tasks[:acceptance_test_target_task] = ["--rm", "awestruct_acceptance_docker_internal"]
      end

      opts.on('--acceptance_test_target HOST_TO_TEST', String, 'runs the cucumber features against the specified HOST_TO_TEST') do |host|
        ENV['HOST_TO_TEST'] = host

        if ENV['RHD_SELENIUM_DRIVER'].to_s.empty?
          ENV['RHD_SELENIUM_DRIVER']='firefox'
        end

        if ENV['PARALLEL_TEST'].to_s.empty?
          ENV['PARALLEL_TEST']='true'
        end

        if host.start_with?("http://docker")
          raise OptionParser::InvalidArgument.new("can't currently test docker, try --acceptance_test_docker")
        end

         tasks[:unit_tests] = unit_test_tasks
         tasks[:kill_all] = true
         tasks[:set_ports] = true
         tasks[:build] = true
         tasks[:supporting_services] += ["selenium-#{ENV['RHD_SELENIUM_DRIVER']}"]
         tasks[:acceptance_test_target_task] = ["--no-deps", "--rm", "awestruct_acceptance_remote_host", "bundle exec rake features HOST_TO_TEST=#{ENV['HOST_TO_TEST']} RHD_SELENIUM_DRIVER=#{ ENV['RHD_SELENIUM_DRIVER']} PARALLEL_TEST=#{ENV['PARALLEL_TEST']}"]
      end

      opts.on('--docker-pr-reap', 'Reap Old Pull Requests') do |pr|
        tasks[:awestruct_command_args] = ["--no-deps", "--rm", "--service-ports", "awestruct", "bundle exec rake reap_old_pulls[pr]"]
        tasks[:supporting_services] = []
        tasks[:build] = true
        tasks[:set_ports] = true
      end

      opts.on('--docker-nightly', 'build for PR Staging') do |pr|
        tasks[:awestruct_command_args] = ["--no-deps", "--rm", "--service-ports", "awestruct", "bundle exec rake create_pr_dirs[docker-nightly,build,docker-nightly] clean deploy[staging_docker]"]
        tasks[:kill_all] = true
        tasks[:build] = true
        tasks[:set_ports] = true
        tasks[:unit_tests] = unit_test_tasks
        tasks[:supporting_services] += %w(mysql searchisko searchiskoconfigure)
      end

      opts.on('--run-the-stack', 'build, restart and preview') do |rts|
        tasks[:decrypt] = true
        tasks[:set_ports] = true
        tasks[:unit_tests] = unit_test_tasks
        tasks[:build] = true
        tasks[:kill_all] = true
        tasks[:supporting_services] += %w(mysql searchisko searchiskoconfigure)
        tasks[:awestruct_command_args] = ['--no-deps', '--rm', '--service-ports', 'awestruct', "rake git_setup clean preview[profile]"]
      end

      # No argument, shows at tail.  This will print an options summary.
      opts.on_tail('-h', '--help', 'Show this message') do
        puts opts
        exit
      end
    end

    if args.empty?
      args += ['-h'] #Show the help
    end

    opts_parse.parse! args

    #Flag to see if anything was set it supporting_services
    tasks[:should_start_supporting_services] = tasks[:supporting_services].size > 1

    # change the profile awestruct runs with
    if tasks[:awestruct_command_args]
      if tasks[:drupal]
        tasks[:awestruct_command_args][-1].gsub! 'profile', 'drupal'
        tasks[:awestruct_command_args][-1].gsub! 'preview', 'gen'
        tasks[:awestruct_command_args].delete '--no-deps'
      else
        tasks[:awestruct_command_args][-1].gsub! 'profile', 'docker'
      end
    end

    tasks
  end

  def self.unit_test_tasks
    ['--no-deps', '--rm', 'awestruct_unit_tests', 'bundle exec rake test']
  end

end

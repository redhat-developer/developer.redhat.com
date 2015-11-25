#For instructions on usage see the README file
require "minitest/reporters"
require 'rake/testtask'
require_relative './_lib/github.rb'

load './_cucumber/cucumber.rake'

$resources = ['stylesheets', 'javascripts', 'images']
$use_bundle_exec = true
$install_gems = ['awestruct -v "~> 0.5.3"', 'rb-inotify -v "~> 0.9.0"']
$awestruct_cmd = nil
$remote = ENV['DEFAULT_REMOTE'] || 'origin'
task :default => :preview

Rake::TestTask.new do |t|
  t.libs = ["_docker/lib"]
  t.warning = false
  t.verbose = true
  t.test_files = FileList['_docker/test/*.rb'] #Let's add more files here!
end

desc 'Setup the environment to run Awestruct'
task :setup, [:env] => [:init, :bundle_install, :git_setup] do |task, args|
  # Don't execute any more tasks, need to reset env
  exit 0
end

task :bundle_install, [:env] do |task, args|
  next if !which('awestruct').nil?

  if File.exist? 'Gemfile'
    if args[:env] == 'local'
      require 'fileutils'
      FileUtils.remove_file 'Gemfile.lock', true
      FileUtils.remove_dir '.bundle', true
      system 'bundle install --binstubs=_bin --path=.bundle'
    else
      system 'bundle install'
    end
  else
    if args[:env] == 'local'
      $install_gems.each do |gem|
        msg "Installing #{gem}..."
        system "gem install --bindir=_bin --install-dir=.bundle #{gem}"
      end
    else
      $install_gems.each do |gem|
        msg "Installing #{gem}..."
        system "gem install #{gem}"
      end
    end
  end
end

desc 'Update the environment to run Awestruct'
task :update => [:init, :git_setup] do
  # Don't execute any more tasks, need to reset env
  exit 0
end

desc 'Initialize any git submodules'
task :git_setup do
  system 'git submodule foreach \'git fetch --tags\''
  system 'git submodule update --init'
end

desc 'Build and preview the site locally in development mode'
task :preview, [:profile] => :check do |task, args|
  profile = args[:profile] || 'development'
  awestruct_running_port = awestruct_port(profile)
  run_awestruct "-P #{profile} -a -s --force -q --auto --livereload -b 0.0.0.0 -p #{awestruct_running_port}"
end

desc 'Generate the site using the defined profile, or development if none is given'
task :gen, [:profile] => :check do |task, args|
  run_awestruct "-P #{args[:profile] || 'development'} -g --force -q"
end

desc "Push local commits to #{$remote}/master"
task :push, [:profile, :tag_name] => :init do |task, args|
  if !args[:tag_name].nil?
    msg "Pushing tags"
    system "git push --tags #{$remote} master"
  end
end

desc 'Tag the source files'
task :tag, [:profile, :tag_name] do |task, args|
  $config ||= config args[:profile]
  if $config['require_tag'] && args[:tag_name].nil?
    msg "Must specify tag_name", :warn
    exit 1
  end
  if !args[:tag_name].nil?
    msg "Tagging '#{args[:tag_name]}'"
    system "git tag #{args[:tag_name]}"
  end
end

desc 'Generate the site and deploy using the given profile'
task :deploy, [:profile, :tag_name] => [:check, :tag, :push] do |task, args|
  msg 'running deploy'
  msg "SEARCHISKO_HOST_PORT: #{ENV['SEARCHISKO_HOST_PORT']}"
  # Delay awestruct failing the build until after we rsync files, if we are staging.
  # Allows errors to be viewed
  begin
    run_awestruct "-P #{args[:profile]} -g --force"
  rescue
    if args[:profile] != 'production'
      msg 'awestruct_failed'
      awestruct_failed = true
    else
      msg 'awestruct_failed, exit'
      exit 1
    end
  end

  $config ||= config args[:profile]

  LOCAL_CDN_PATH = Pathname.new('_tmp').join('cdn') # HACK!!
  local_site_path = '_site' # HACK!!

  # Update the resources on the CDN.
  if $config['cdn_http_base']
    cdn_host = $config.deploy.cdn_host
    cdn_path = $config.deploy.cdn_path

    if args[:tag_name]
      local_originals_path = LOCAL_CDN_PATH.join(args[:tag_name])
    else
      if ENV['site_path_suffix']
        local_originals_path = LOCAL_CDN_PATH.join("#{ENV['site_path_suffix']}").join("originals")
      else
        local_originals_path = LOCAL_CDN_PATH.join("originals")
      end
    end

    # Collect our original resources, for others to use
    FileUtils.mkdir_p local_originals_path
    $resources.each do |r|
      src = Pathname.new(local_site_path).join(r)
      FileUtils.cp_r src, local_originals_path if File.exist? src
    end

    rsync(local_path: LOCAL_CDN_PATH, host: cdn_host, remote_path: cdn_path)
  end

  # Deploy the site
  # If we are running a non-site root build (e.g. Pull Request) we alter where the site is copied too, and we don't delete
  if ENV['site_path_suffix']
    site_path = "#{$config.deploy.path}/#{ENV['site_path_suffix']}"
    delete = false
  else
    site_path = $config.deploy.path
    delete = true
  end
  site_host = $config.deploy.host
  rsync(local_path: local_site_path, host: site_host, remote_path: site_path, delete: delete, excludes: $resources + ['.snapshot'])
  if awestruct_failed
    exit 1
  end
end

desc 'Clean out generated site and temporary files'
task :clean, :spec do |task, args|
  msg 'running clean'
  require 'fileutils'
  dirs = ['.awestruct', '.sass-cache', '_site']
  if args[:spec] == 'all'
    dirs << '_tmp'
  end
  dirs.each do |dir|
    FileUtils.remove_dir dir unless !File.directory? dir
  end
end

# Perform initialization steps, such as setting up the PATH
task :init, [:profile] do
  # Detect using gems local to project
  if File.exist? '_bin'
    ENV['PATH'] = "_bin#{File::PATH_SEPARATOR}#{ENV['PATH']}"
    ENV['GEM_HOME'] = '.bundle'
  end
end

desc 'Check to ensure the environment is properly configured'
task :check => :init do
  if !File.exist? 'Gemfile'
    if which('awestruct').nil?
      msg 'Could not find awestruct.', :warn
      msg 'Run `rake setup` or `rake setup[local]` to install from RubyGems.'
      # Enable once the rubygem-awestruct RPM is available
      #msg 'Run `sudo yum install rubygem-awestruct` to install via RPM. (Fedora >= 18)'
      exit 1
    else
      $use_bundle_exec = false
      next
    end
  end

  begin
    require 'bundler'
    Bundler.setup
  rescue LoadError
    $use_bundle_exec = false
  rescue StandardError => e
    msg e.message, :warn
    if which('awestruct').nil?
      msg 'Run `rake setup` or `rake setup[local]` to install required gems from RubyGems.'
    else
      msg 'Run `rake update` to install additional required gems from RubyGems.'
    end
    exit e.status_code
  end
end

desc 'Comment to any mentioned JIRA issues that the changes can now be viewed. Close the issue, if it is in the resolved state already.'
task :comment_and_close_jiras, [:job, :build_number, :deploy_url] do |task, args|
  jenkins = Jenkins.new
  jira = JIRA.new

  # Read the changes
  changes = jenkins.read_changes(args[:job], args[:build_number])

  # Comment on any JIRAs
  jira.comment_issues(changes[:issues], "Successfully deployed to #{args[:deploy_url]} at #{Time.now}")
end

desc 'Comment to any mentioned JIRA issues that the changes can now be viewed. Close the issue, if it is in the resolved state already.'
task :list_jiras, [:job, :build_number] do |task, args|
  jenkins = Jenkins.new

  # Read the changes
  changes = jenkins.read_changes(args[:job], args[:build_number])

  msg changes[:issues]
end

desc 'Comment to any mentioned JIRA issues that the changes can now be viewed.'
task :comment_jiras_from_git_log, [:deploy_url, :not_on] do |task, args|
  jira = JIRA.new
  git = Git.new

  # Comment on any JIRAs
  jira.comment_issues(git.extract_issues('HEAD', args[:not_on]), "Successfully deployed to #{args[:deploy_url]} at #{Time.now}")
end

desc 'Link pull requests to JIRAs.'
task :link_pull_requests_from_git_log, [:pull_request, :not_on] do |task, args|
  jira = JIRA.new
  git = Git.new

  # Link pull requests to JIRA
  linked_issues = jira.link_pull_requests_if_unlinked(git.extract_issues('HEAD', args[:not_on]), args[:pull_request])
  # Add links to JIRA to pull requests
  GitHub.link_issues('redhat-developer', 'developers.redhat.com', args[:pull_request], linked_issues)
  msg "Successfully commented JIRA issue list on https://github.com/redhat-developer/developers.redhat.com/pull/#{args[:pull_request]}"
end

desc 'Remove staged pull builds for pulls closed more than 7 days ago'
task :reap_old_pulls, [:pr_prefix] do |task, args|
  reap = GitHub.list_closed_pulls('redhat-developer', 'developers.redhat.com')
  $staging_config ||= config 'staging'
  Dir.mktmpdir do |empty_dir|
    reap.each do |p|
      msg "Reaping staging and cdn for Pull ##{p}"
      # Clear the path on the html staging server
      rsync(local_path: empty_dir, host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{args[:pr_prefix]}/#{p}", delete: true, ignore_non_existing: true)
      # Clear the path on the cdn
      rsync(local_path: empty_dir, host: $staging_config.deploy.cdn_host, remote_path: "#{$staging_config.deploy.cdn_path}/#{args[:pr_prefix]}/#{p}", delete: true, ignore_non_existing: true)
    end
  end
end

desc 'Make sure Pull Request dirs exist'
task :create_pr_dirs, [:pr_prefix, :build_prefix, :pull] do |task, args|
  msg 'running create_pr_dirs'
  $staging_config ||= config 'staging'
  Dir.mktmpdir do |empty_dir|
    rsync(local_path: empty_dir, host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{args[:pr_prefix]}")
    rsync(local_path: empty_dir, host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{args[:pr_prefix]}/#{args[:pull]}")
    rsync(local_path: empty_dir, host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{args[:pr_prefix]}/#{args[:pull]}/#{args[:build_prefix]}")
    rsync(local_path: empty_dir, host: $staging_config.deploy.cdn_host, remote_path: "#{$staging_config.deploy.cdn_path}/#{args[:pr_prefix]}")
    rsync(local_path: empty_dir, host: $staging_config.deploy.cdn_host, remote_path: "#{$staging_config.deploy.cdn_path}/#{args[:pr_prefix]}/#{args[:pull]}")
    rsync(local_path: empty_dir, host: $staging_config.deploy.cdn_host, remote_path: "#{$staging_config.deploy.cdn_path}/#{args[:pr_prefix]}/#{args[:pull]}/#{args[:build_prefix]}")
  end
end

desc 'Generate a wraith config file'
task :generate_wraith_config, [:old, :new, :pr_prefix, :build_prefix, :pull, :build] do |task, args|
  require 'yaml/store'

  cfg = '_wraith/configs/config.yaml'
  FileUtils.cp '_wraith/configs/template_config.yaml', cfg
  config = YAML::Store.new(cfg)

  new_path = "#{args[:new]}/#{args[:pr_prefix]}/#{args[:pull]}/#{args[:build_prefix]}/#{args[:build]}"

  config.transaction do
    config['domains']['production'] = args[:old]
    config['domains']['pull-request'] = new_path
    config['sitemap'] = "#{new_path}/sitemap.xml"
  end
end

desc 'Run wraith'
task :wraith, [:old, :new, :pr_prefix, :build_prefix, :pull, :build] => :generate_wraith_config do |task, args|
  $staging_config ||= config 'staging'
  Dir.chdir("_wraith")
  unless system "bundle exec wraith capture config"
    exit 1
  end
  wraith_base_path = "#{args[:pr_prefix]}/#{args[:pull]}/wraith"
  wraith_path = "#{wraith_base_path}/#{args[:build]}"
  Dir.mktmpdir do |empty_dir|
    rsync(local_path: empty_dir, host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{wraith_base_path}")
  end
  rsync(local_path: 'shots', host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{wraith_path}")
  GitHub.comment_on_pull('redhat-developer', 'developers.redhat.com', args[:pull], "Visual diff: #{args[:new]}/#{wraith_path}/gallery.html")
end

desc 'Run blinkr'
task :blinkr, [:new, :pr_prefix, :build_prefix, :pull, :build, :verbose] do |task, args|
  $staging_config ||= config 'staging'
  base_path = "#{args[:pr_prefix]}/#{args[:pull]}"
  base_url = "#{args[:new]}/#{base_path}/#{args[:build_prefix]}/#{args[:build]}/"
  report_base_path = "#{base_path}/blinkr"
  report_path = "#{report_base_path}/#{args[:build]}"
  verbose_switch = args[:verbose] == 'verbose' ? '-v' : ''
  FileUtils.rm_rf("_tmp/blinkr")
  FileUtils.mkdir_p("_tmp/blinkr")
  unless system "bundle exec blinkr -c _config/blinkr.yaml -u #{base_url} #{verbose_switch}"
    exit 1
  end
  Dir.mktmpdir do |empty_dir|
    rsync(local_path: empty_dir, host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{report_base_path}")
  end
  rsync(local_path: '_tmp/blinkr', host: $staging_config.deploy.host, remote_path: "#{$staging_config.deploy.path}/#{report_path}")
  report_filename = File.basename YAML::load_file('_config/blinkr.yaml')['report']
  GitHub.comment_on_pull('redhat-developer', 'developers.redhat.com', args[:pull], "Blinkr: #{args[:new]}/#{report_path}/#{report_filename}")
end

# Execute Awestruct
def run_awestruct(args)

  if ENV['site_base_path']
    base_url = ENV['site_base_path']
    base_url = "#{base_url}/#{ENV['site_path_suffix']}" if ENV['site_path_suffix']
  end
  args ||= "" # Make sure that args is initialized
  args << " --url " + base_url if base_url
  msg "Executing awestruct with args #{args}" 
  unless system "#{$use_bundle_exec ? 'bundle exec ' : ''}awestruct #{args}"
    raise "Error executing awestruct"
  end
end

# A cross-platform means of finding an executable in the $PATH.
# Respects $PATHEXT, which lists valid file extensions for executables on Windows
#
#  which 'awestruct'
#  => /usr/bin/awestruct
def which(cmd, opts = {})
  unless $awestruct_cmd.nil? || opts[:clear_cache]
    return $awestruct_cmd
  end

  $awestruct_cmd = nil
  exts = ENV['PATHEXT'] ? ENV['PATHEXT'].split(';') : ['']
  ENV['PATH'].split(File::PATH_SEPARATOR).each do |path|
    exts.each do |ext|
      candidate = File.join path, "#{cmd}#{ext}"
      if File.executable? candidate
        $awestruct_cmd = candidate
        return $awestruct_cmd
      end
    end
  end
  return $awestruct_cmd
end

def awestruct_port(profile)
  if profile.to_sym == :docker || profile.to_sym == :drupal
    #If we're in docker we want to run the whole awestruct preview on the same port
    ENV['AWESTRUCT_HOST_PORT']
  else
    4242
  end
end

# Print a message to STDOUT
def msg(text, level = :info)
  case level
  when :warn
    puts "\e[31m#{text}\e[0m"
  else
    puts "\e[33m#{text}\e[0m"
  end
end

def rsync(local_path:, host:, remote_path:, delete: false, excludes: [], dry_run: false, verbose: false, ignore_non_existing: false)
  unless File.exist?(ENV['HOME']+'/.ssh/id_rsa')
    abort("#{ENV['HOME']}+'/.ssh/id_rsa' does not exists. Rsync will fail")
  end
  msg "Deploying #{local_path} to #{host}:#{remote_path} via rsync"
  cmd = "rsync --partial --archive --checksum --compress --omit-dir-times #{'--quiet' unless verbose} #{'--verbose' if verbose} #{'--dry-run' if dry_run} #{'--ignore-non-existing' if ignore_non_existing} --chmod=Dg+sx,ug+rw,Do+rx,o+r --protocol=28 #{'--delete ' if delete} #{excludes.collect { |e| "--exclude " + e}.join(" ")} #{local_path}/ #{host}:#{remote_path}"
  msg "Rsync command: #{cmd}" if verbose
  unless open3(cmd) == 0
    msg "error executing rsync, exiting"
    exit 1
  end
end

def open3(cmd)
  require 'open3'
  Open3.popen3( cmd ) do |_, stdout, stderr, wait_thr|
    threads = []
    threads << Thread.new(stdout) do |i|
      while ( ! i.eof? )
        msg i.readline
      end
    end
    threads << Thread.new(stderr) do |i|
      while ( ! i.eof? )
        msg i.readline, :error
      end
    end
    threads.each{|t|t.join}
    wait_thr.value
  end
end

def config(profile = nil)
  load_site_yaml "_config/site.yml", profile
end

def load_site_yaml(yaml_path, profile = nil)
  require 'awestruct/astruct'
  require 'awestruct/page'
  config = Awestruct::AStruct.new
  if ( File.exist?( yaml_path ) )
    require 'yaml'
    data = YAML.load( File.read( yaml_path ) )
    if ( profile )
      profile_data = {}
      data.each do |k,v|
        if ( ( k == 'profiles' ) && ( ! profile.nil? ) )
          profile_data = ( v[profile] || {} )
        else
          config.send( "#{k}=", merge_data( config.send( "#{k}" ), v ) )
        end
      end if data
      config.profile = profile
      profile_data.each do |k,v|
        config.send( "#{k}=", merge_data(config.send( "#{k}" ), v ) )
      end
    else
      data.each do |k,v|
        config.send( "#{k}=", v )
      end if data
    end
  end
  config
end

def merge_data(existing, new)
  if existing.kind_of? Hash
    result = existing.inject({}) do |merged, (k,v)|
      if new.has_key? k
        if v.kind_of? Hash
          merged[k] = merge_data(v, new.delete(k))
        else
          merged[k] = new.delete(k)
        end
      else
        merged[k] = v
      end
      merged
    end
    result.merge new
  else
    new
  end
end

require 'net/http'
require 'uri'
require 'json'
require 'date'
require 'tmpdir'

class Git
  def extract_issues(branch, not_on)
    # Read the changes
    changes = `git --no-pager log #{branch} --not #{not_on}`
    changes.scan(JIRA::KEY_PATTERN).flatten.uniq
  end
end

class Jenkins

  def initialize
    @jenkins_base_url = ENV['jenkins_base_url'] || 'http://jenkins.mw.lab.eng.bos.redhat.com/hudson/'
    unless ENV['jenkins_username'] && ENV['jenkins_password']
    end
  end

  def read_changes(job, build_number)
    url = @jenkins_base_url
    url << "job/#{job}/#{build_number}/api/json?wrapper=changes"
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path)
    if ENV['jenkins_username'] && ENV['jenkins_password']
      req.basic_auth ENV['jenkins_username'], ENV['jenkins_password']
    end
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    resp = http.request(req)
    issues = []
    commits = []
    if resp.is_a?(Net::HTTPSuccess)
        json = JSON.parse(resp.body)
        json['changeSet']['items'].each do |item|
          commits << item['commitId']
          issues << item['comment'].scan(JIRA::KEY_PATTERN)
        end
    else
      msg "Error loading changes from Jenkins using #{url}. Status code #{resp.code}. Error message #{resp.body}"
    end
    # There can be multiple comments per issue
    {:issues => issues.flatten.uniq, :commits => commits}
  end

end

class JIRA

  KEY_PATTERN = /(?:[[:punct:]]|\s|^)([A-Z]+-[0-9]+)(?=[[:punct:]]|\s|$)/

  def initialize
    @jira_base_url = ENV['jira_base_url'] || 'https://issues.jboss.org/'
    @jira_issue_base_url = "#{@jira_base_url}rest/api/2/issue/"
    unless ENV['jira_username'] && ENV['jira_password']
      abort 'Must provide jira_username and jira_password environment variables'
    end
  end

  def comment_issues(issues, comment)
    issues.each do |k|
      url = "#{@jira_issue_base_url}#{k}/comment"
      body = %Q{{ "body": "#{comment}"}}
      resp = post(url, body)
      if resp.is_a?(Net::HTTPSuccess)
        msg "Successfully commented on #{k}"
      else
        msg "Error commenting on #{k} in JIRA. Status code #{resp.code}. Error message #{resp.body}"
        msg "Request body: #{body}"
      end
    end
  end

  def issue_status(issue)
    url = "#{@jira_issue_base_url}#{issue}?fields=status"
    resp = get(url)
    if resp.is_a?(Net::HTTPSuccess)
      json = JSON.parse(resp.body)
      if json['fields'] && json['fields']['status'] && json['fields']['status']['name']
        json['fields']['status']['name']
      else
        msg "Error fetching status of #{issue} from JIRA. Status field not present"
        -1
      end
    else
      msg "Error fetching status of #{issue} from JIRA. Status code #{resp.code}. Error message #{resp.body}"
      -1
    end
  end

  def linked_pull_request(issue)
    url = "#{@jira_issue_base_url}#{issue}?fields=customfield_12310220"
    resp = get(url)
    if resp.is_a?(Net::HTTPSuccess)
      json = JSON.parse(resp.body)
      if json['fields'] && json['fields']['customfield_12310220']
        json['fields']['customfield_12310220']
      end
    else
      msg "Error fetching linked pull request for #{issue} from JIRA. Status code #{resp.code}. Error message #{resp.body}"
      -1
    end
  end

  def post(url, body)
    uri = URI.parse(url)
    req = Net::HTTP::Post.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.basic_auth ENV['jira_username'], ENV['jira_password']
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req.body = body
    http.request(req)
  end

  def get(url)
    uri = URI.parse(url)
    req = Net::HTTP::Get.new(uri.path, initheader = {'Content-Type' =>'application/json'})
    req.basic_auth ENV['jira_username'], ENV['jira_password']
    http = Net::HTTP.new(uri.host, uri.port)
    if uri.scheme == 'https'
      http.use_ssl = true
    end
    http.request(req)
  end

  def link_pull_requests_if_unlinked(issues, pull_request)
    linked_issues = []
    issues.each do |k|
      pr = linked_pull_request k
      if pr.nil?
        url = "#{@jira_issue_base_url}#{k}/transitions"
        body = %Q{
          {
            "update": {
              "customfield_12310220": [
                {
                  "set": "https://github.com/redhat-developer/developers.redhat.com/pull/#{pull_request}"
                }
              ]
            },
            "transition": {
              "id": "131"
            }
          }
        }
        resp = post(url, body)
        if resp.is_a?(Net::HTTPSuccess)
          msg "Successfully linked https://github.com/redhat-developer/developers.redhat.com/pull/#{pull_request} to #{k}"
        else
          msg "Error linking https://github.com/redhat-developer/developers.redhat.com/pull/#{pull_request} to #{k} in JIRA. Status code #{resp.code}. Error message #{resp.body}"
          msg "Request body: #{body}"
        end
        linked_issues << k
      end
    end
    linked_issues
  end
end

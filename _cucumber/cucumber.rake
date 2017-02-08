require 'fileutils'
require_relative 'test_runner'

task features: [:rubocop, :_features, :json_merge, :report_builder]

task :_features do
  if ENV['RHD_TEST_PROFILE']
    @profile = ENV['RHD_TEST_PROFILE']
  else
    @profile = 'desktop'
    ENV['RHD_TEST_PROFILE'] = @profile
  end

  ENV['RHD_REMOTE_BROWSER'] = nil if ENV['RHD_REMOTE_BROWSER'].to_s.empty?

  if ENV['CUCUMBER_TAGS'].to_s.empty?
    tags = nil
  else
    tag_arr = []
    if ENV['CUCUMBER_TAGS'].include?(',')
      tag = ENV['CUCUMBER_TAGS'].split(',')
      tag.each do |cuke_tag|
        tag_arr << "--tags #{cuke_tag}"
      end
      tags = tag_arr.join(' ')
    else
      tags = "--tags #{ENV['CUCUMBER_TAGS']}"
    end
  end
  test_runner = TestRunner.new
  test_runner.cleanup(@profile)
  @exit_status = test_runner.run(@profile, tags)
end

task :json_merge do
  cucumber_dir = File.dirname(__FILE__)
  c = CucumberJSONMerger.new(@profile)
  c.run
  c.rerun
  c.rerun_2
  File.open("#{cucumber_dir}/reports/#{@profile}/combined.json", 'w+').write c.master.to_json
  file = File.join("#{cucumber_dir}/reports/#{@profile}/", 'cucumber*')
  files = Dir.glob(file)
  files.each do |f|
    File.delete(f)
  end
  File.delete("#{cucumber_dir}/reports/#{@profile}/rerun.json") if File.exist?("#{cucumber_dir}/reports/#{@profile}/rerun.json")
  File.delete("#{cucumber_dir}/reports/#{@profile}/rerun2.json") if File.exist?("#{cucumber_dir}/reports/#{@profile}/rerun2.json")
end

task :report_builder do
  test_runner = TestRunner.new
  test_runner.generate_report(@profile)
  exit(@exit_status)
end

task :cuke_sniffer do
  test_runner = TestRunner.new
  test_runner.cuke_sniffer
end

task :rubocop do
  test_runner = TestRunner.new
  test_runner.code_analyzer
end

task wip: [:rubocop, :_wip]

task :_wip do
  test_runner = TestRunner.new
  test_runner.wip
end

task :debugger do
  system("parallel_cucumber #{File.dirname(__FILE__)}/features/ -o \"--tags @debug\" -n 10")
end

task :debug, :times do |_task, args|
  args[:times].to_i.times { Rake::Task[:debugger].execute }
end

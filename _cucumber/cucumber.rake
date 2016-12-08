require 'fileutils'
require_relative 'test_runner'

task features: [:rubocop, :_features, :report_builder]

task :_features do
  if ENV['RHD_TEST_PROFILE']
    @profile = ENV['RHD_TEST_PROFILE']
  else
    @profile = 'desktop'
    ENV['RHD_TEST_PROFILE'] = @profile
  end

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
  system('cucumber _cucumber -r _cucumber/features/ --tags @debug')
end

task :debug, :times do |args|
  puts "Executing scenario tagged with @debug #{args[:times]} times"
  args[:times].to_i.times { Rake::Task[:debugger].execute }
end

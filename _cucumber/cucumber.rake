require 'rubygems'
require 'cucumber'
require 'cucumber/rake/task'
require 'parallel'
require 'fileutils'

Cucumber::Rake::Task.new(:wip) do |t|
  t.cucumber_opts = '_cucumber -r _cucumber/features/ --profile wip'
end

task :cleanup do
  puts '======== Deleting old reports and logs ========='
  FileUtils.rm_rf('_cucumber/reports')
  File.delete('cucumber_failures.log') if File.exist?('cucumber_failures.log')
  File.new('cucumber_failures.log', 'w')
  Dir.mkdir('_cucumber/reports')
end

task :parallel_features do
  result = system "parallel_cucumber _cucumber/features/ -o \"-p parallel\" -n 20"
  result
end

task :rerun do
  if File.size('cucumber_failures.log') == 0
    puts '========= No failures. Everything Passed ========='
  else
    puts '========= Re-running Failed Scenarios ========='
    exit_code = system 'bundle exec cucumber @cucumber_failures.log -f pretty'
    result = $?.success?
    fail ('Cucumber tests failed') if exit_code == false && result == false
  end
end

task :features => [:cleanup, :parallel_features, :rerun]

task :cuke_sniffer do
  sh 'bundle exec cuke_sniffer --out html reports/cuke_sniffer.html'
end

task :rubocop do
  sh 'bundle exec rubocop features/'
end

task :police => [:cleanup, :cuke_sniffer]

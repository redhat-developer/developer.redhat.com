require 'report_builder'
require 'colorize'
require 'colorized_string'

class TestRunner

  def cleanup(profile)

    FileUtils.rm_rf("_cucumber/reports/#{profile}")
    FileUtils.mkdir_p("_cucumber/reports/#{profile}")

    FileUtils.rm_rf("_cucumber/screenshots/#{profile}")
    FileUtils.mkdir_p("_cucumber/screenshots/#{profile}")

    FileUtils.rm_rf("_cucumber/tmp/#{profile}")
    FileUtils.mkdir_p("_cucumber/tmp/#{profile}")

  end

  def run(profile, tag=nil)
    tag_string = tag unless tag.eql?(nil)
    if tag.eql?(nil)
      command = system "parallel_cucumber _cucumber/features/ -o \"-p #{profile}\" -n 10"
    else
      command = system("parallel_cucumber _cucumber/features/ -o \"-p #{profile} #{tag_string}\" -n 10")
    end
    rerun(profile) unless command == true
    $?.exitstatus
  end

  def rerun(profile)
    puts ColorizedString.new('. . . . . There were failures during the test run! Attempt one of rerunning failed scenarios . . . . .').red
    command = system('bundle exec cucumber --profile rerun_failures')
    unless command == true
      puts ColorizedString.new('. . . . . There were failures during first rerun! Attempt two of rerunning failed scenarios . . . . .').red
      system("bundle exec cucumber @_cucumber/tmp/#{profile}/rerunner.txt")
    end
    $?.exitstatus
  end

  def generate_report(profile)
    ReportBuilder.configure do |config|
      config.json_path = "_cucumber/reports/#{profile}"
      config.report_path = "_cucumber/reports/#{profile}/rhd_#{profile}_test_report"
      config.report_types = [:json, :html]
      config.report_tabs = [:overview, :features, :errors]
      config.report_title = "RHD #{profile.capitalize} Test Report"
      config.compress_images = true
    end
    ReportBuilder.build_report
  end

end

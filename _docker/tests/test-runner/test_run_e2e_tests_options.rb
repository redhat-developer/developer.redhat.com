require 'minitest/autorun'
require 'mocha/mini_test'

require_relative '../test_helper'
require_relative '../../../_tests/lib/run_test_options'

class TestRunTestOptions < MiniTest::Test

  def setup
    @test_dir = '_tests'
    @run_tests_options = RunTestOptions.new(@test_dir)
    clear_env_variables
  end

  def teardown
    clear_env_variables
  end

  def clear_env_variables
    ENV['github_status_sha1'] = nil
    ENV['github_status_context'] = nil
    ENV['rhd_test'] = 'e2e'
    ENV['HOST_TO_TEST'] = nil
    ENV['RHD_JS_DRIVER'] = nil
  end

  def test_non_docker_e2e_test_execution_no_base_url_specified
    Kernel.expects(:abort).with('Please specify a base url. For example --base-url=http://foo.com')
    test_configuration = @run_tests_options.parse_command_line(%w(--e2e))
    assert_equal('chrome', test_configuration[:browser])
    assert_equal("cd #{@test_dir}/e2e && npm test -- --baseUrl=", test_configuration[:run_tests_command])
  end

  def test_docker_e2e_test_execution_no_base_url_specified
    Kernel.expects(:abort).with('Please specify a base url. For example --base-url=http://foo.com')
    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --use-docker --browser=chrome))
    assert_equal('chrome', test_configuration[:browser])
    assert_equal('npm test -- --baseUrl=', test_configuration[:run_tests_command])
  end

  def test_non_docker_e2e_test_execution
    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com))
    refute(test_configuration[:docker])
    assert_equal('chrome', test_configuration[:browser])
    assert_equal("cd #{@test_dir}/e2e && npm test -- --baseUrl=http://foo.com", test_configuration[:run_tests_command])
    assert_equal(nil, ENV['github_status_sha1'])
    assert_equal(nil, ENV['github_status_context'])
  end

  def test_default_execution_using_docker
    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker))
    assert(test_configuration[:docker])
    assert_equal('chrome', test_configuration[:browser])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
    assert_equal('chrome', ENV['RHD_JS_DRIVER'])
    assert_equal(nil, ENV['github_status_sha1'])
    assert_equal(nil, ENV['github_status_context'])
  end

  def test_non_docker_execution_specifying_unknown_mobile_device

    Kernel.expects(:abort).with("Invalid device specified! Device 'foo' was not found. \nSee available test devices here: '_tests/e2e/config/chromium_devices.json'")

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --browser=foo))

    assert_equal('foo', test_configuration[:browser])
    assert_equal('foo', ENV['RHD_JS_DRIVER'])
    assert_equal("cd #{@test_dir}/e2e && npm test -- --baseUrl=http://foo.com", test_configuration[:run_tests_command])
  end

  def test_docker_execution_specifying_unknown_mobile_device

    Kernel.expects(:abort).with("Invalid device specified! Device 'foo' was not found. \nSee available test devices here: '_tests/e2e/config/chromium_devices.json'")

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker --browser=foo))

    assert(test_configuration[:docker])
    assert_equal('foo', test_configuration[:browser])
    assert_equal('foo', ENV['RHD_JS_DRIVER'])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
  end

  def test_non_docker_execution_specifying_unknown_browserstack_browser

    Kernel.expects(:abort).with("Invalid remote browser specified! Browser 'bs_foo' \n See available browserstack options here: '_tests/e2e/config/remote_browsers.json' \n Set desired stack using --browser=bs_ie_11")

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-browserstack --browser=bs_foo))
    assert_equal('bs_foo', test_configuration[:browser])
    assert_equal('bs_foo', ENV['RHD_JS_DRIVER'])
    assert_equal("cd #{@test_dir}/e2e && npm test -- --baseUrl=http://foo.com", test_configuration[:run_tests_command])
  end

  def test_docker_execution_specifying_unknown_browserstack_browser

    Kernel.expects(:abort).with("Invalid remote browser specified! Browser 'bs_foo' \n See available browserstack options here: '_tests/e2e/config/remote_browsers.json' \n Set desired stack using --browser=bs_ie_11")

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker --use-browserstack --browser=bs_foo))
    assert(test_configuration[:docker])
    assert_equal('bs_foo', test_configuration[:browser])
    assert_equal('bs_foo', ENV['RHD_JS_DRIVER'])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
  end


  def test_docker_execution_specifying_update_github_status
    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker --update-github-status=123))
    assert(test_configuration[:docker])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
    assert_equal('123', ENV['github_status_sha1'])
    assert_equal('FE:node-e2e-tests', ENV['github_status_context'])
    assert_equal('true', ENV['github_status_enabled'])
  end

  def test_docker_execution_specifying_mobile_device

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker --browser=iphone_6))

    assert(test_configuration[:docker])
    assert_equal('iphone_6', test_configuration[:browser])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
    assert_equal('iPhone 6', ENV['RHD_JS_DRIVER'])
    assert_equal('chrome', test_configuration[:docker_node])
    assert_equal(nil, ENV['github_status_sha1'])
    assert_equal(nil, ENV['github_status_context'])
  end

  def test_docker_execution_specifying_docker_firefox_browser

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker --browser=firefox))

    assert(test_configuration[:docker])
    assert_equal('firefox', test_configuration[:browser])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
    assert_equal('firefox', ENV['RHD_JS_DRIVER'])
    assert_equal('firefox', test_configuration[:docker_node])
    assert_equal(nil, ENV['github_status_sha1'])
    assert_equal(nil, ENV['github_status_context'])
  end

  def test_docker_execution_specifying_remote_browser

    ENV['RHD_BS_AUTHKEY'] = '12345'
    ENV['RHD_BS_USERNAME'] = 'foobar'

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-docker --use-browserstack --browser=bs_ie_11))

    assert(test_configuration[:docker])
    assert(test_configuration[:browserstack])
    assert_equal('bs_ie_11', test_configuration[:browser])
    assert_equal('npm test -- --baseUrl=http://foo.com', test_configuration[:run_tests_command])
    assert_equal('bs_ie_11', ENV['RHD_JS_DRIVER'])
    assert_equal('chrome', test_configuration[:docker_node])
    assert_equal(nil, ENV['github_status_sha1'])
    assert_equal(nil, ENV['github_status_context'])
    assert_equal('12345', ENV['RHD_BS_AUTHKEY'])
    assert_equal('foobar', ENV['RHD_BS_USERNAME'])
  end

  def test_non_docker_execution_specifying_remote_browser

    ENV['RHD_BS_AUTHKEY'] = '12345'
    ENV['RHD_BS_USERNAME'] = 'foobar'

    test_configuration = @run_tests_options.parse_command_line(%w(--e2e --base-url=http://foo.com --use-browserstack --browser=bs_ie_11))

    assert(test_configuration[:browserstack])
    assert_equal('bs_ie_11', test_configuration[:browser])
    assert_equal("cd #{@test_dir}/e2e && npm test -- --baseUrl=http://foo.com", test_configuration[:run_tests_command])
    assert_equal('bs_ie_11', ENV['RHD_JS_DRIVER'])
    assert_equal(nil, ENV['github_status_sha1'])
    assert_equal(nil, ENV['github_status_context'])
    assert_equal('12345', ENV['RHD_BS_AUTHKEY'])
    assert_equal('foobar', ENV['RHD_BS_USERNAME'])
  end

end

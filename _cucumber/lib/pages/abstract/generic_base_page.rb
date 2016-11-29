class GenericBasePage

  def initialize(browser, visit = false)
    @browser = browser
    go_to if visit
    expected_element if respond_to? :expected_element
    has_expected_title? if respond_to? :has_expected_title?
  end

  def self.page_url(url)
    define_method 'go_to' do
      open(url)
    end
  end

  def open(url)
    if url.include?('realms')
      @browser.goto($keycloak_base_url + url)
    else
      @browser.goto($host_to_test + url)
    end
  end

  def self.expected_element(type, identifier)
    define_method 'expected_element' do
      @browser.send("#{type.to_s}", identifier).wait_until(message: "Element #{identifier} was not visible after 30 seconds", &:present?)
    end
  end

  def self.page_title(expected_title)
    define_method 'has_expected_title?' do
      has_expected_title = expected_title.kind_of?(Regexp) ? expected_title =~ @browser.title : expected_title == @browser.title
      raise "Expected title '#{expected_title}' instead of '#{title}'" unless has_expected_title
    end
  end

  def wait_for_ajax(message = nil)
    end_time = ::Time.now + 30
    until ::Time.now > end_time
      return if @browser.execute_script("return window.jQuery != undefined && jQuery.active == 0")
      sleep 0.5
    end
    message = 'Timed out waiting for ajax requests to complete' unless message
    raise message
  end

  def method_missing(sym, *args, &block)
    @browser.send(sym, *args, &block)
  end

  def self.element(element_name)
    define_method(element_name.to_s) do
      yield self
    end
  end

  class << self
    alias :value :element
    alias :elements :element
    alias :action :element
  end

end

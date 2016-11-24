module DriverHelper

  def type(locator, string)
    locator.set(string)
  end

  def default_dropdown_item(locator)
    locator.selected_options[0].text
  end

  def dropdown_items(locator)
    items = []
    values = locator.options
    values.each { |co| items << co.text }
    items
  end

  def press_return
    @browser.send_keys :enter
  end

  def custom_find(el, locator)
    el.find_element(locator)
  end

  def custom_click_on(el, locator)
    el.find_element(locator).click
  end

  def current_window
    @browser.driver.window_handle
  end

  def get_windows
    @browser.driver.window_handles
    @browser.driver.window_handles.map do |w|
      @browser.driver.switch_to.window(w)
      [w, @browser.driver.title]
    end
  end

  def wait_for_windows(size)
    get_windows.size == size
  end

  def switch_window(first_window)
    all_windows = @browser.driver.window_handles
    all_windows.select { |this_window| this_window != first_window }
    @browser.driver.close
    @browser.driver.switch_to.window(first_window)
  end

  def close_and_reopen_browser
    @browser.driver.execute_script("window.open()")
    @browser.driver.close
    @browser.driver.switch_to.window(@browser.driver.window_handles.last)
  end

end

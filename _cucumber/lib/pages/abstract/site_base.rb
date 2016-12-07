require_relative 'generic_base_page'
require_relative '../../../../_cucumber/lib/helpers/driver_helper'
require_relative '../../../../_cucumber/lib/helpers/page_helper'

# this class inherits from the GenericBasePage class, it contains a set of common site wide elements and methods. All pages will inherit from this.
class SiteBase < GenericBasePage
  include DriverHelper, PageHelper

  element(:nav)                     { |b| b.element(class: 'logged-in') }
  element(:login_link)              { |b| b.li(class: 'login') }
  element(:logout_link)             { |b| b.link(class: 'logout') }
  element(:register_link)           { |b| b.li(class: 'register') }
  element(:logged_in_name)          { |b| b.li(class: 'logged-in-name') }
  element(:mobile_menu)             { |b| b.link(class: 'nav-toggle') }
  element(:site_nav_search_box)     { |b| b.text_field(css: '.accounts .search-wrapper .user-search') }
  element(:search_button)           { |b| b.button(id: 'search-button') }
  element(:logged_in)               { |b| b.li(class: 'logged-in') }
  element(:mobile_nav)              { |b| b.element(class: 'nav-open') }
  element(:kc_feedback_text)        { |b| b.element(class: 'kc-feedback-text') }
  element(:topics_link)             { |b| b.link(text: 'Topics') }
  element(:technologies_link)       { |b| b.link(text: 'Technologies') }
  element(:community_link)          { |b| b.link(text: 'Community') }
  element(:help_link)               { |b| b.link(text: 'Help') }
  element(:downloads_link)          { |b| b.link(text: 'Downloads') }
  element(:sub_nav)                 { |b| b.li(class: 'sub-nav-open') }
  element(:topics_sub_nav)          { |b| b.div(id: 'sub-nav-topics') }
  element(:technologies_sub_nav)    { |b| b.div(id: 'sub-nav-technologies') }
  element(:community_sub_nav)       { |b| b.div(id: 'sub-nav-community') }
  element(:help_sub_nav)            { |b| b.div(id: 'sub-nav-help') }
  element(:referral_alert)          { |b| b.element(id: 'referral-alert') }

  value(:search_field_visible?)     { |p| p.site_nav_search_box.present? }
  value(:is_mobile?)                { |p| p.mobile_menu.present? }
  value(:mobile_menu_open?)         { |p| p.mobile_nav.present? }
  value(:is_logged_in?)             { |p| p.logged_in.present? }
  value(:is_logged_out?)            { |p| p.login_link.present? }
  value(:kc_feedback)               { |p| p.kc_feedback_text.text }

  action(:click_login_link)         { |p| p.login_link.click }
  action(:click_logout_link)        { |p| p.logout_link.click }
  action(:click_register_link)      { |p| p.register_link.click }
  action(:toggle_mobile_menu)       { |p| p.mobile_menu.click }
  action(:click_search_button)      { |p| p.search_button.click }

  def search_for(search_string)
    enter_search_term(search_string)
    begin
      press_return
    rescue
      click_search_button
    end
  end

  def enter_search_term(search_string)
    toggle_menu
    type(site_nav_search_box, search_string)
  end

  def toggle_menu
    toggle_mobile_menu if is_mobile? unless mobile_menu_open?
  end

  def toggle_menu_close
    toggle_mobile_menu && sub_nav.wait_while(&:present?) if mobile_menu_open?
  end

  def open_login_page
    toggle_menu if is_mobile?
    click_login
  end

  def open_register_page
    toggle_menu if is_mobile?
    click_register
  end

  def logged_in?
    toggle_menu if is_mobile?
    logged_in.wait_while { |el| el.text == '' }
    logged_in.text
  end

  def logged_out?
    toggle_menu if is_mobile?
    is_logged_out?
  end

  def click_login
    toggle_menu if is_mobile?
    click_login_link
  end

  def click_logout
    toggle_menu if is_mobile?
    click_logout_link
  end

  def click_register
    toggle_menu if is_mobile?
    click_register_link
  end

  def click_profile
    toggle_menu if is_mobile?
  end

  def toggle_menu_and_tap(menu_item)
    toggle_menu
    click_on_nav_menu(menu_item)
  end

  def click_on_nav_menu(menu_item)
    send("#{menu_item.downcase}_link").click
  end

  def menu_item_present?(menu_item)
    toggle_menu if is_mobile?
    case menu_item
      when 'login'
        login_link.present?
      when 'register'
        register_link.present?
      else
        send("#{menu_item}_link").present?
    end
  end

  def sub_menu_items(menu_item)
    send("#{menu_item}_sub_nav").text
  end

  def get_href_for(link)
    href = @browser.a(text: /#{link}/)
    href.attribute_value('href')
  end

end

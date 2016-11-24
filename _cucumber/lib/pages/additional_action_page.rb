require_relative 'abstract/site_base'

class AdditionalActionPage < SiteBase
  expected_element(:h1, text: 'Additional Action Required')
  #page_title('Additional Action Required | Red Hat Developers')

  element(:email_field)                  { |b| b.text_field(id: 'email') }
  element(:email_field_error)            { |b| b.element(id: 'email-error')}
  element(:password_field)               { |b| b.text_field(id: 'user.attributes.pwd') }
  element(:confirm_password_field)       { |b| b.text_field(id: 'password-confirm') }
  element(:first_name_field)             { |b| b.text_field(id: 'firstName') }
  element(:last_name_field)              { |b| b.text_field(id: 'lastName') }
  element(:city_field)                   { |b| b.text_field(id: 'user.attributes.addressCity') }
  element(:company_field)                { |b| b.text_field(id: 'user.attributes.company') }
  element(:phone_number_field)           { |b| b.text_field(id: 'user.attributes.phoneNumber') }
  element(:phone_number_field_error)     { |b| b.text_field(id: 'user.attributes.phoneNumber-error') }
  element(:country_dropdown)             { |b| b.select_list(id: 'user.attributes.country') }
  element(:state_dropdown)               { |b| b.select_list(id: 'user.attributes.addressState') }
  element(:all_terms)                    { |b| b.checkbox(id: 'tac-checkall') }
  element(:tac1)                         { |b| b.checkbox(id: 'user.attributes.tcacc-6') }
  element(:tac2)                         { |b| b.checkbox(id: 'user.attributes.tcacc-1246') }
  element(:submit_btn)                   { |b| b.button(value: 'Submit') }
  element(:link_profile_to_social)       { |b| b.link(text: 'Link your social account with the existing account.') }
  element(:warning)                      { |b| b.element(class: 'warning') }

  action(:accept_all_terms)              { |p| p.all_terms.click }
  action(:accept_tac1)                   { |p| p.tac1.click }
  action(:accept_tac2)                   { |p| p.tac2.click }
  action(:click_submit)                  { |p| p.submit_btn.click }
  action(:click_link_profile_to_social)  { |p| p.link_profile_to_social.click }

  value(:feedback)                       { |p| p.warning.text }
  value(:email_field_error_text)         { |p| p.email_field_error.text }

  def fill_in(email, password, first_name, last_name, company, phone_number, country, city, state)
    type(email_field, email) unless email.nil?
    enter_password(password, password) unless password.nil?
    type(first_name_field, first_name) unless first_name.nil?
    type(last_name_field, last_name) unless last_name.nil?
    type(company_field, company) unless company.nil?
    type(phone_number_field, phone_number) unless phone_number.nil?
    select_country(country) unless country.nil?
    select_state(state) unless state.nil?
    type(city_field, city) unless city.nil?
  end

  def enter_email(email)
    type(email_field, email)
  end

  def enter_password(password, confirm_password)
    type(password_field, password)
    type(confirm_password_field, confirm_password)
  end

  def select_country(country)
    country_dropdown.select(country)
  end

  def select_state(state)
    state_dropdown.select(state)
  end

  def enter_city(city)
    type(city_field, city)
  end

  def enter_phone_number(phone_number)
    type(phone_number_field, phone_number)
  end

  def enter_company(company)
    type(company_field, company)
  end

  def fulluser_tac_accept
    accept_tac1
    accept_tac2
  end

end

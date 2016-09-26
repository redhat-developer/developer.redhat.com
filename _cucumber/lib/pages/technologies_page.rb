require_relative 'abstract/site_base'

class TechnologiesPage < SiteBase
  page_url('/products/')
  expected_element(:h2, text: 'Technologies')
  #page_title('Red Hat Products')

  element(:products_sections)                      { |b| b.divs(css: '.development-tool') }
  elements(:products_links)                        { |b| b.divs(css: '.development-tools h4 > a') }

  def product_title(category)
    @browser.div(id: "#{category}").when_present.text
  end

  def available_products
    products = []
    products_links.each do |el|
      products << el.text
    end
    products
  end

  def product_section_for(product)
    @browser.div(id: "development-tool-#{product}").when_present.text
  end

  def product_description_for(product)
    @browser.element(css: "#development-tool-#{product} .paragraph").when_present.text
  end

  def product_link_for(product)
    @browser.link(id: "#{product}").href
  end

  def get_started_button_for(product)
    @browser.link(id: "get-started-with-#{product}").href
  end

  def learn_link_for(product)
    @browser.link(id: "learn-#{product}").href
  end

  def docs_and_apis_for(product)
    @browser.link(id: "#{product}-docs-and-apis").href
  end

  def download_button_for(product)
    @browser.link(id: "download-#{product}").href
  end

end

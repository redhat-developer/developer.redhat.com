require_relative 'base_page.rb'
require_relative '../../../_cucumber/lib/helpers/products_helper.rb'

class DownloadsPage < BasePage
  set_url '/downloads/'

  class << self
    include ProductsHelper
  end

  element  :products, '#downloads'
  elements :download_latest_links, '.fa-download'
  elements :product_downloads, 'h5 > a'
  elements :other_resources, :xpath, '//*[@id="other-resources"]/ul/li'

  # PRODUCTS.each_with_index do |product, i|
  #   element :"#{product.downcase.tr(' ', '_')}_download_link", :xpath, "(//a[contains(text(),'Download Latest')])[#{i+1}]"
  # end

  def initialize(driver)
    super
  end

  def open
    load
    loaded?('Downloads available from JBoss')
  end

  def available_downloads
    products = []
    product_downloads.map { |name|
      products << name.text }
    products
  end

  def other_resources_links
    other_resources.map { |link| p link.text }
  end

end

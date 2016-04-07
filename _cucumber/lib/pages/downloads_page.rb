require_relative 'base_page'
require_relative '../../../_cucumber/lib/helpers/downloads_helper.rb'

class DownloadsPage < BasePage
  set_url '/downloads/'

  class << self
    include DownloadHelper
  end

  element :most_popular_downloads_section, '.most-popular-downloads'
  elements :fetching_download_spinner, '.fa-refresh'
  elements :download_latest_btn, '#downloads .fa-download'
  elements :most_popular_download_btn, '.most-popular-downloads .fa-download'
  elements :product_downloads, '#downloads h5'
  elements :other_resources, :xpath, '//*[@id="other-resources"]/ul/li'

  def initialize(driver)
    super
  end

  def open
    load
    verify_page('Downloads | Red Hat Developers')
  end

  def available_downloads
    products = []
    product_downloads.map { |name|
      products << name.text }
    products
  end

  def other_resources_links
    other_resources.map { |link| link.text.capitalize }
  end

end

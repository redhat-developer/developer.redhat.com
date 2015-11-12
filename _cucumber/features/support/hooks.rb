Before do
  @driver = Capybara.current_session.driver
  @page = App.new(@driver)
  if Capybara.current_driver == 'poltergeist'.to_sym
    @driver.clear_cookies
  else
    @driver.browser.manage.delete_all_cookies
  end
end

Before('@products, @downloads') do
  @product_ids = get_products[0]
  @product_names = get_products[1]
  @products_with_learn_link = get_products_with_links('learn.html.slim')[0]
  @products_with_docs = get_products_with_links('docs-and-apis.adoc')[0]
  @products_with_downloads = get_products_with_links('download.adoc')[0]
  @products_with_buzz = get_products_with_links('buzz.html.slim')[0]
end

After do |scenario|
  if scenario.failed?
    Capybara.using_session(Capybara::Screenshot.final_session_name) do
      filename_prefix = Capybara::Screenshot.filename_prefix_for(:cucumber, scenario)

      saver = Capybara::Screenshot::Saver.new(Capybara, Capybara.page, true, filename_prefix)
      saver.save
      saver.output_screenshot_path

      if File.exist?(saver.screenshot_path)
        require 'base64'
        image = open(saver.screenshot_path, 'rb') { |io| io.read }
        encoded_img = Base64.encode64(image)
        embed(encoded_img, 'image/png;base64', "Screenshot of the error")
      end
    end
  end
end

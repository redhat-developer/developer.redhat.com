Then(/^I should see products sections f:$/) do |table|
  on ForumsPage do |page|
    table.raw.each do |sections|
      section = sections.first
      expect(page.forums_product_sections).to include section
    end
  end
end

Then(/^I should see the following forum products:$/) do |table|
  on ForumsPage do |page|
    products, @product_ids = page.available_products
    expected_products = []
    data = table.raw
    data.each { |row| expected_products << row }
    products.should =~ expected_products.flatten
  end
end

Then(/^each product title should link to the relevant product forum page$/) do
  on ForumsPage do |page|
    @product_ids.each do |product|
      if product == 'dotnet'
        expect(page.forums_product_link_for(product)).to include "developer.jboss.org/en/topics/#{product}"
      else
        expect(page.forums_product_link_for(product)).to include "developer.jboss.org/en/products/#{product}"
      end
    end
  end
end

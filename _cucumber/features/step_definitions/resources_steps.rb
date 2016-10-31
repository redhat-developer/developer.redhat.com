Then(/^none of the product filters should be checked$/) do
  on ResourcesPage do |page|
    el = page.any_checked?
    el.should_not include true
  end
end

Then(/^I should see "([^"]*)" results ordered by (.*)$/) do |results_size, default_sort|
  on ResourcesPage do |page|
    page.results_sort[0].should == default_sort
    all_results = page.results_date
    top_result = all_results.first
    results = all_results - [top_result]
    results.each { |date|
      raise("Results were not ordered by most recent, the order was #{results}") unless DateTime.parse(date) <= DateTime.parse(top_result)
    }
  end
end

When(/^I click to filter results by "([^"]*)"$/) do |filter_type|
  on ResourcesPage do |page|
    page.send("filter_by_#{filter_type.downcase.gsub(' ', '_')}")
    page.wait_for_results
    @results = page.results
  end
end

Then(/^the results should be filtered by (.*)$/) do |filter|
  on ResourcesPage do |page|
    page.results_contain_img_for(filter).should == true
  end
end

When(/^I uncheck the "([^"]*)" filter$/) do |filter_type|
  on ResourcesPage do |page|
    page.send("filter_by_#{filter_type.downcase.gsub(' ', '_')}")
    page.wait_for_results
  end
end

Then(/^the default set of results are displayed$/) do
  on ResourcesPage do |page|
    page.results.should_not =~ @results
  end
end

And(/^the results for "([^"]*)" are displayed$/) do |filter_type|
  on ResourcesPage do |page|
    page.results_contain_img_for(filter_type).should == true
  end
end

And(/^the results displayed should not contain "([^"]*)"$/) do |filter_type|
  on ResourcesPage do |page|
    page.results_contain_img_for(filter_type).should_not == true
  end
end

Then(/^the max characters on the Keyword field should be set to "([^"]*)"$/) do |arg|
  on ResourcesPage do |page|
    page.keyword_field.attribute('maxlength').should == arg
  end
end

When(/^I enter "([^"]*)" into the Keyword's box$/) do |search_string|
  on ResourcesPage do |page|
    page.keyword_search(search_string)
  end
end

Then(/^the results displayed should contain "([^"]*)"$/) do |search_string|
  on ResourcesPage do |page|
    results = page.results
    results.each { |res| res.should include search_string }
  end
end

Then(/^the results displayed should contain "([^"]*)" or "([^"]*)"$/) do |term1, term2|
  on ResourcesPage do |page|
    results = page.results
    results.each { |res|
      result = res.downcase.include?(term1.downcase) || res.downcase.include?(term2.downcase)
      result.should be true
    }
  end
end

Then(/^some of the results should contain a "([^"]*)" tag$/) do |tag|
  on ResourcesPage do |page|
    results = page.tags
    occurrences = Hash.new(0)
    results.each do |v|
      occurrences[v.downcase] += 1
    end
    occurrences["#{tag.downcase}"].should be >= 1
  end
end

When(/^select "([^"]*)" from the product filter$/) do |product|
  on ResourcesPage do |page|
    @initial_results = page.results
    page.filter_by_product(product)
  end
end

Then(/^the results should be updated$/) do
  on ResourcesPage do |page|
    updated_results = page.results
    @initial_results.should_not == updated_results
  end
end

When(/^I change the Publish date drop down menu to "([^"]*)"$/) do |date_type|
  on ResourcesPage do |page|
    page.filter_by_publish_date(date_type)
  end
end

Then(/^all of the results should contain a "([^"]*)" thumbnail$/) do |filter|
  on ResourcesPage do |page|
    page.results_contain_img_for(filter).should == true
  end
end

Then(/^the results should be from "([^"]*)"$/) do |publish_date|
  on ResourcesPage do |page|
    results = page.results_date
    top_result = results.first
    results.delete(top_result)
    results.each do |date|
      remaining = DateTime.parse(date).to_date.to_s
      case publish_date
        when 'Past Day'
          valid = Date.today - 1 <= Date.parse(remaining, "%d-%m-%Y")
        when 'Past Week'
          valid = Date.today - 7 <= Date.parse(remaining, "%d-%m-%Y")
        when 'Past Month'
          valid = Date.today.prev_month <= Date.parse(remaining, "%d-%m-%Y")
        when 'Past Quarter'
          q = Date.today.quarter
          valid = q <= Date.parse(remaining, "%d-%m-%Y").quarter
        when 'Past Year'
          valid = Date.today.prev_year <= Date.parse(remaining, "%d-%m-%Y")
        else
          raise("#{publish_date} is not a valid filter type")
      end
      valid.should == true
    end
  end
end

And(/^results have loaded$/) do
  on ResourcesPage do |page|
    page.wait_for_results
    @initial_results = page.results
  end
end

When(/^I select "([^"]*)" from the results per page filter$/) do |results_per_page|
  on ResourcesPage do |page|
    page.select_results_per_page(results_per_page)
  end
end

class Date
  def quarter
    case self.month
      when 1, 2, 3
        return 1
      when 4, 5, 6
        return 2
      when 7, 8, 9
        return 3
      when 10, 11, 12
        return 4
    end
  end
end

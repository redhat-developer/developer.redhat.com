# this module contains 'visit' and 'on' methods that were created as a maintainable way of initialising/navigating to pages. (lib/pages)
module PageHelper
  attr_reader :current_page

  def visit(page_class, &block)
    on(page_class, true, &block)
  end

  def on(page_class, visit=false, &block)
    page = page_class.new(@browser, visit)
    block.call page if block
    @current_page = page
  end
end

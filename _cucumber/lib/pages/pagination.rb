require_relative 'base'

class Pagination < Base

  RESULTS_TEXT             = { css: '#paginator > span' }
  PAGINATION               = { class: 'pagination' }
  CURRENT_LINK             = { class: 'current' }

  def initialize(driver)
    super
    wait_for { displayed?(PAGINATION) }
  end

  def results_text
    wait_for { displayed?(RESULTS_TEXT) }
    text_of(RESULTS_TEXT)
  end

  def has_pagination?
    displayed?(PAGINATION)
  end

  def has_ellipsis?
    text_of(css: "#pagination-#{5}").include?('⋯')
  end

  def has_pagination_with(i)
    wait_for(12) { displayed?(SEARCH_RESULTS_CONTAINER) && displayed?(PAGINATION) }
    displayed?(css: "#pagination-#{i}")
  end

  def pagination_links(link, link_state)
    if link_state == 'enabled'
      case link
        when 'previous'
          displayed?(css: "#pagination-prev.available")
        else
          displayed?(css: "#pagination-#{link}.available")
      end
    else
      case link
        when 'previous'
          displayed?(css: "#pagination-prev.unavailable")
        else
          displayed?(css: "#pagination-#{link}.unavailable")
      end
    end
  end

  def click_pagination(link)
    case link
      when 'first', 'next', 'last'
        wait_for { displayed?(css: "#pagination-#{link}") }
        click_on(css: "#pagination-#{link}")
      when 'previous'
        wait_for { displayed?(css: "#pagination-prev") }
        click_on(css: "#pagination-prev")
      else
        wait_for { displayed?(css: "#pagination-#{link.to_i-1}") }
        click_on(css: "#pagination-#{link.to_i-1}")
    end
    wait_for_ajax
  end

  def current_link
    wait_for(12) { displayed?(PAGINATION) }
    text_of(CURRENT_LINK)
  end

end

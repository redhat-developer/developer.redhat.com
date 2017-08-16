require 'cgi'
require 'nokogiri'
require 'fileutils'
require_relative '../default_logger'
require_relative 'export_urls'

#
# This class is used to post-process an httrack export of a site. It performs primarily 2 tasks:
#
# 1: Post process the HTML to improve site structure
# 2: Add in static resources e.g. robots.txt, .htaccess files that are not included by the httrack export process
#
# The primary reason for this thing existing is that we wish to maintain a trailing URL structure when the site is exported
# e.g. https://developers.redhat.com/containers/ and not https://developers.redhat.com/containers.html
#
# Default out-of-the-box, we can only do the latter with Httrack, hence all of this post-processing logic to get us to the former!
#
class ExportHtmlPostProcessor

  include RedhatDeveloper::Export::Urls

  def initialize(process_runner, static_file_directory)
    @log = DefaultLogger.logger
    @process_runner = process_runner
    @static_file_directory = static_file_directory
  end

  #
  # Locates the link back to the index of the site. This is required so that we can re-write the search
  # form target to be relative to the current page.
  #
  def locate_index_link_href(html_document, html_page)
      home_link = html_document.css('#home-link')
      raise StandardError.new("Unable to locate link to index.html on page '#{html_page}'") if home_link.empty?
      raise StandardError.new("Found more than one link with id 'home-link' on page '#{html_page}'") if home_link.length > 1
      home_link.first.attributes['href'].value
  end

  #
  # Copies in the static resources that should be part of the export directory structure.
  #
  def copy_static_resources(export_directory)
    @log.info("Copying static resources from '#{@static_file_directory}' to '#{export_directory}'...")
    FileUtils.cp_r("#{@static_file_directory}/.", export_directory)
    @log.info("Completed copy of static resources from '#{@static_file_directory}'.")
  end

  #
  # Performs post-processing on the HTML export to make it fit the requiring site structure.
  #
  def post_process_html_export(drupal_host, export_directory)
    relocate_index_html(export_directory)
    rewrite_links_for_trailing_slash_url_structure(export_directory)
    post_process_html_dom(drupal_host, export_directory)
    copy_static_resources(export_directory)
  end

  #
  # Uses sed to re-write links within the HTML pages of the export to:
  #
  # 1: Point to the newly located index.html
  # 2: Remove the index.html part of any link within the export that points to a page within the export
  #
  def rewrite_links_for_trailing_slash_url_structure(export_directory)

    # These should be executed as a single command, but I cannot get that to work for love nor money
    @process_runner.execute!("find #{export_directory} -name '*.html' -type f -print0 | xargs -0 sed -i'' -e s:'index\\/index.html':'':g")
    @process_runner.execute!("find #{export_directory} -name '*.html' -type f -print0 | xargs -0 sed -i'' -e s:'\\/index.html':'\\/':g")
    @process_runner.execute!("find #{export_directory} -name '*.html' -type f -print0 | xargs -0 sed -i'' -e s:'index.html':'\\.\\/':g")
  end

  #
  # See https://issues.jboss.org/browse/DEVELOPER-3500
  #
  # After Httrack has run there is some mark-up in the exported HTML that identifies the host from which it mirrored the site. This is a minor
  # security issue, as we're leaking the host name of Drupal outside our controlled network.
  #
  # I attempted to turn off this mark-up generation in Drupal, but as with most things, Drupal just ignores you.
  #
  # Anyways, here we remove the <link rel="shortlink"/> , <link rel="revision"/> and <meta name="Generator"/> mark-up from the DOM.
  # @return true if the DOM was modified, false otherwise
  #
  def remove_drupal_host_identifying_markup?(html_doc)
    elements_to_remove = html_doc.css('link[rel="shortlink"],link[rel="revision"],meta[name="Generator"]')
    elements_to_remove.each do | element |
      element.remove
    end

    if elements_to_remove.size > 0
      @log.info("\tRemoved Drupal host identifying markup.")
    end

    elements_to_remove.size > 0
  end


  #
  # This method gives us the chance to make any amendments to the DOM within all HTML files contained
  # within the export
  #
  def post_process_html_dom(drupal_host, export_directory)

    Dir.glob("#{export_directory}/**/*.html") do | html_file |
      @log.info("Post-processing HTML DOM in file '#{html_file}'...")

      html_doc = File.open(html_file) do | file |
        Nokogiri::HTML(file)
      end

      hide_drupal = remove_drupal_host_identifying_markup?(html_doc)
      rewrite_forms = rewrite_form_target_urls?(drupal_host, html_doc, html_file)
      rewrite_access_links = rewrite_access_redhat_com_links(html_doc, html_file)

      if hide_drupal || rewrite_forms || rewrite_access_links
        @log.info("DOM in file '#{html_file}' has been modified, writing new file to disk.")
        File.open(html_file,'w') do | file |
          file.write(html_doc.to_html)
        end
      end

      rewrite_error_page(html_doc, html_file)
    end
  end

  #
  # Re-writes the relative links on the error pages to be absolute so that they work from any part of the site
  # hierarchy.
  #
  def rewrite_error_page(html_doc, html_file)
    return unless html_file.end_with?('/404-error/index.html') || html_file.end_with?('/general-error/index.html')
    home_link = locate_index_link_href(html_doc, html_file)
    final_base_url = final_base_url_location

    @log.info("\t Re-writing absolute links starting '#{home_link}' to have absolute prefix '#{final_base_url}' on error page #{html_file}...")
    new_content = File.read(html_file).gsub(home_link, final_base_url)
    File.open(html_file, 'w') do |write|
      write.puts(new_content)
    end
  end

  #
  # Moves the index/index.html file up one directory so that the home-page is served by default when browsing
  # to the root of the directory
  #
  def relocate_index_html(export_directory)
    FileUtils.mv("#{export_directory}/index/index.html", "#{export_directory}/index.html")
    FileUtils.rm_rf("#{export_directory}/index")
    @process_runner.execute!("sed -i'' -e s:'\\.\\.\\/':'':g #{export_directory}/index.html")
    @log.info("Moved #{export_directory}/index/index.html to #{export_directory}/index.html.")
  end

  #
  # Re-writes the action attribute of any form on the page where the action is pointing to the host from
  # which we have exported the HTML content
  #
  def rewrite_form_target_urls?(drupal_host, html_doc, html_file_name)

    forms_to_modify = html_doc.css("form[action^=\"http://#{drupal_host}\"]")
    forms_to_modify.each do | form |
      home_link_href = locate_index_link_href(html_doc, html_file_name)
      new_action_value = "#{home_link_href}search/"

      @log.info("\tModifying form action '#{form.attributes['action']}' to '#{new_action_value}'")
      form.attributes['action'].value = new_action_value
    end
    forms_to_modify.size > 0

  end

  #
  # access.redhat.com links are broken when we strip off the trailing "/index.html" to fix the site export structure.
  # This fixes that.
  #
  def rewrite_access_redhat_com_links(html_doc, html_file_name)
    links_to_modify = html_doc.css("body a[href*=\"access.redhat.com\"]")
    modified = false
    links_to_modify.each do | link |
      if link.attributes['href'].value.include?('documentation')
        new_href = "#{link.attributes['href']}/index.html"
        @log.info("\tModifying documentation link #{link.attributes['href'].to_s} to #{new_href}")
        link.attributes['href'].value = new_href
        modified = true
      end
    end

    modified

  end


  private :final_base_url_location, :locate_index_link_href, :rewrite_links_for_trailing_slash_url_structure, :rewrite_form_target_urls?, :relocate_index_html, :remove_drupal_host_identifying_markup?, :post_process_html_dom

end



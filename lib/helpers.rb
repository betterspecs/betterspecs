include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Breadcrumbs
include Nanoc3::Helpers::XMLSitemap
require 'builder'
require 'fileutils'
require 'time'

# Hyphens are converted to sub-directories in the output folder.
#
# If a file has two extensions like Rails naming conventions, then the first extension
# is used as part of the output file.
#
#   sitemap.xml.erb # => sitemap.xml
#
# If the output file does not end with an .html extension, item[:layout] is set to 'none'
# bypassing the use of layouts.
# 
def route_path(item)
  # in-memory items have not file
  return item.identifier + "index.html" if item[:content_filename].nil?
  
  url = item[:content_filename].gsub(/^content/, '')
 
  # determine output extension
  extname = '.' + item[:extension].split('.').last
  outext = '.haml'
  if url.match(/(\.[a-zA-Z0-9]+){2}$/) # => *.html.erb, *.html.md ...
    outext = '' # remove 2nd extension
  elsif extname == ".sass"
    outext = '.css'
  else
    outext = '.html'
  end
  url.gsub!(extname, outext)
  
  if url.include?('-')
    url = url.split('-').join('/')  # /2010/01/01-some_title.html -> /2010/01/01/some_title.html
  end

  url
end

# Creates in-memory tag pages from partial: layouts/_tag_page.haml
def create_tag_pages
  tag_set(items).each do |tag|
    items << Nanoc3::Item.new(
      "<%= render('tags', :tag => '#{tag}') %>", # use locals to pass data
      {:is_hidden => true}, # do not include in sitemap.xml
      "/blog/tags/#{tag}/", # identifier
      :binary => false
    )
  end
end


# Add update time to articles
def add_update_item_attributes
  changes = MGutz::FileChanges.new

  items.each do |item|
    # do not include assets or xml files in sitemap
    if item[:content_filename]
      ext = File.extname(route_path(item))
      item[:is_hidden] = true if item[:content_filename] =~ /assets\// || ext == '.xml'
    end

    if item[:kind] == "article"
      # filename might contain the created_at date
      item[:created_at] ||= derive_created_at(item)
      # sometimes nanoc3 stores created_at as Date instead of String causing a bunch of issues
      item[:created_at] = item[:created_at].to_s if item[:created_at].is_a?(Date)

      # sets updated_at based on content change date not file time
      change = changes.status(item[:content_filename], item[:created_at], item.raw_content)
      item[:updated_at] = change[:updated_at].to_s
    end
  end
end


# Copy static assets outside of content instead of having nanoc3 process them.
def copy_static
  FileUtils.cp_r 'assets/.', 'public/' 
end

def partial(identifier_or_item)
  item = !item.is_a?(Nanoc3::Item) ? identifier_or_item : item_by_identifier(identifier_or_item)
  item.compiled_content(:snapshot => :pre) 
end

def item_by_identifier(identifier)
  items ||= @items
  items.find { |item| item.identifier == identifier }
end

#=> { 2010 => { 12 => [item0, item1], 3 => [item0, item2]}, 2009 => {12 => [...]}}
def articles_by_year_month
  result = {}
  current_year = current_month = year_h = month_a = nil

  sorted_articles.each do |item|
    d = Date.parse(item[:created_at])
    if current_year != d.year
      current_month = nil
      current_year = d.year
      year_h = result[current_year] = {}
    end

    if current_month != d.month
      current_month = d.month
      month_a = year_h[current_month] = [] 
    end

    month_a << item
  end

  result
end

def is_front_page?
    @item.identifier == '/'
end


def n_newer_articles(n, reference_item)
  @sorted_articles ||= sorted_articles
  index = @sorted_articles.index(reference_item)
  
  # n = 3, index = 4
  if index >= n
    @sorted_articles[index - n, n]
  elsif index == 0
    []
  else # index < n
    @sorted_articles[0, index]
  end
end


def n_older_articles(n, reference_item)
  @sorted_articles ||= sorted_articles
  index = @sorted_articles.index(reference_item)
  
  # n = 3, index = 4, length = 6
  length = @sorted_articles.length
  if index < length
    @sorted_articles[index + 1, n]
  else
    []
  end
end


def site_name
  @config[:site_name]
end

def pretty_time(time)
  Time.parse(time).strftime("%b %d, %Y") if !time.nil?
end

def featured_cout
  @config[:featured_count].to_i
end

def excerpt_count
  @config[:excerpt_count].to_i
end

def disqus_shortname 
  @config[:disqus_shortname]
end

def to_month_s(month)
  Date.new(2010, month).strftime("%B")
end

def name(item)
  item.identifier.split("/").last 
end

private

def derive_created_at(item)
  parts = item.identifier.gsub('-', '/').split('/')[1,3]
  date = '1980/1/1'
  begin
    Date.strptime(parts.join('/'), "%Y/%m/%d")
    date = parts.join('/')
  rescue
  end
  date
end



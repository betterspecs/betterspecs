include Nanoc3::Helpers::Blogging
include Nanoc3::Helpers::Breadcrumbs
include Nanoc3::Helpers::Capturing
include Nanoc3::Helpers::Filtering
include Nanoc3::Helpers::HTMLEscape
include Nanoc3::Helpers::LinkTo
include Nanoc3::Helpers::Rendering
include Nanoc3::Helpers::Tagging
include Nanoc3::Helpers::Text
include Nanoc3::Helpers::XMLSitemap

class Nanoc3::Item

  # Get the item content
  def content(opts = {})
    opts[:rep] ||= :default
    opts[:snapshot] ||= :last
    reps.find { |r| r.name == opts[:rep] }.content_at_snapshot(opts[:snapshot])
  end

  # Get the item name
  #
  #   /blog/domotics-explained   # domotics-explained
  def name
    identifier.split("/").last 
  end

  # Prettify the name for the home page box system
  def subtitle
   # <span class="label"><span>C</span>onnect <span>A</span>ll <span>D</span>evices</span></a> 
   self[:subtitle].split(' ').map {|w| '<span>' + w[0] + '</span>' + w[1..-1] }.join(' ')
  end

  # Prettify the name for the home page box system
  def title
   # <span class="label"><span>C</span>onnect <span>A</span>ll <span>D</span>evices</span></a> 
   self[:title].split(' ').map {|w| '<span>' + w[0] + '</span>' + w[1..-1] }.join(' ')
  end
end

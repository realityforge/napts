module MenuHelper
  if ! const_defined?(:Link)
    Link = Struct.new( "Link", :name, :link_options, :html_options, :options )
    
    UserLink = 
      Link.new('User: ', 
               nil,
               {:title => 'Currently logged in user'},
               {}).freeze
    SignOutLink = 
      Link.new('Sign Out', 
               {:controller => 'login', :action => 'logout'},
               {:title => 'Logout', :post => true},
               {}).freeze
  end

  def render_links(links,html_options)
    text = ''
    links.each do |link|
      text += "<li>#{render_link(link)}</li>"
    end
    content_tag("ul",text,html_options)
  end

  def render_link(link)
    html_options = link.html_options.dup
    html_options['class'] = 'selected' if link.options[:selected]
    if link.link_options
      text = link_to(link.name, link.link_options, html_options)
    else
      text = content_tag("span",link.name,html_options)
    end
    text
  end

  def get_user_links
    links = []
    links << gen_user_link.freeze
    links << SignOutLink
    links
  end

  def gen_user_link
    link = UserLink.dup
    link.name += @user.name
    link
  end
end

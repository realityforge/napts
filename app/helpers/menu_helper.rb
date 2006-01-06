module MenuHelper
  if true || ! const_defined?(:Link)
    Link = Struct.new( "Link", :name, :link_options, :html_options, :options )
    
    HomeLink = Link.new('Home',
      {:controller => 'welcome', :action => 'index'},
      {:title => 'Return to Home page'},
      {}).freeze
    PastQuizzesLink = Link.new('Results',
      {:controller => 'results', :action => 'statistics'},
      {:title => 'Results for completed OnLine Tests'},
      {}).freeze
    CurrentQuizzesLink = Link.new('Take Test',
      {:controller => 'quiz_attempt', :action => 'intro'},
      {:title => 'Sit enabled online test'},
      {}).freeze
    PreviewQuizzesLink = Link.new('Preview Tests',
      {:controller => 'preview_quiz', :action => 'intro'},
      {:title => 'Preview tests'},
      {}).freeze
    CreateQuestionsLink = Link.new('Create Questions',
      {:controller => 'question', :action => 'new'},
      {:title => 'add a new question to the database'},
      {}).freeze
    UserLink = Link.new('User: ', 
      nil, 
      {:title => 'Currently logged in user'},
      {}).freeze
    SignOutLink = Link.new('Sign Out', 
      {:controller => 'login', :action => 'logout'},
      {:title => 'Logout', :post => true},
      {}).freeze
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

  def render_links(links,html_options)
    text = ''
    links.each do |link|
      text += "<li>#{render_link(link)}</li>"
    end
    content_tag("ul",text,html_options)
  end

  def render_link(link)
    html_options = link.html_options.dup
    STDERR.puts html_options.inspect 
    html_options['class'] = 'selected' if link.options[:selected]
    if link.link_options
      text = link_to(link.name, link.link_options, html_options)
    else
      text = content_tag("span",link.name,html_options)
    end
    text
  end
  
  def get_navigation_links
    links = []
    links << HomeLink
    links << gen_past_quizzes_link.freeze
    links << gen_current_quizzes_link.freeze
    links << gen_preview_quizzes_link.freeze
    links << gen_create_questions_link.freeze
    links
  end
  
  def get_controller_name
    controller.controller_name
  end
  
  def dup_link_with_select( link, is_selected )
    result = link.dup
    result.options.update(:selected => is_selected )
    result
  end
 
  def gen_past_quizzes_link
    is_selected = get_controller_name == 'results' && @action_name == 'statistics'
    dup_link_with_select( PastQuizzesLink, is_selected )
  end
  
  def gen_create_questions_link
    is_selected = get_controller_name == 'question' && @action_name == 'new'
    dup_link_with_select( CreateQuestionsLink, is_selected )
  end
  
  def gen_current_quizzes_link
    is_selected = get_controller_name == 'quiz_attempt' && @action_name == 'intro'
    dup_link_with_select( CurrentQuizzesLink, is_selected )
  end
  
  def gen_preview_quizzes_link
    is_selected = get_controller_name == 'preview_quiz' && @action_name == 'intro'
    dup_link_with_select( PreviewQuizzesLink, is_selected )
  end
end

module MenuHelper
  if ! const_defined?(:Link)
    Link = Struct.new( "Link", :name, :link_options, :html_options, :options )

    ManageQuizzesLink = Link.new('Manage Quizzes',
      {:controller => '/teachers/quizzes', :action => 'list'},
      {:title => 'Create new quizzes or add and remove questions from existing quizzes'},
      {}).freeze
    ManageQuestionsLink = Link.new('Manage Questions',
      {:controller => '/teachers/question', :action => 'list'},
      {:title => 'Add, remove or edit questions and answers'},
      {}).freeze

    UserLink = Link.new('User: ',
      nil,
      {:title => 'Currently logged in user'},
      {}).freeze
    SubjectLink = Link.new('Subject: ',
      nil,
      {:title => 'Currently logged in subject'},
      {}).freeze
    RoleLink = Link.new('  Role: ',
      nil,
      {:title => 'Current Role'},
      {}).freeze
    SignOutLink = Link.new('Sign Out',
      {:controller => '/login', :action => 'logout'},
      {:title => 'Logout', :post => true},
      {}).freeze
  end

  def get_user_links
    links = []
    links << gen_user_link.freeze
    if session[:role] == :teacher ||  session[:role] == :demonstrator
      links << gen_subject_link.freeze
    end
    links << gen_role_link.freeze
    links << SignOutLink
    links
  end

  def gen_user_link
    link = UserLink.dup
    link.name += current_user.name
    link
  end

  def gen_subject_link
    link = SubjectLink.dup
    link.name += current_subject.name
    link
  end

  def gen_role_link
    link = RoleLink.dup
    link.name += session[:role].to_s
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
    if session[:role] == :teacher
      links << gen_manage_quizzes_link.freeze
      links << gen_manage_questions_link.freeze
    end
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

  def gen_manage_quizzes_link
    is_selected = get_controller_name == '/teachers/quizzes' && @action_name == 'list'
    dup_link_with_select( ManageQuizzesLink, is_selected )
  end

   def gen_manage_questions_link
    is_selected = get_controller_name == '/teachers/question' && @action_name == 'list'
    dup_link_with_select( ManageQuestionsLink, is_selected )
  end
end

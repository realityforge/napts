module MenuHelper
  if ! const_defined?(:Link)
    Link = Struct.new( "Link", :name, :link_options, :html_options, :options )

    HomeLink = Link.new('Home',
      {:controller => 'welcome', :action => 'index'},
      {:title => 'Return to Home page'},
      {}).freeze
    PastQuizzesLink = Link.new('Results',
      {:controller => '/students/results', :action => 'statistics'},
      {:title => 'Results for completed OnLine Tests'},
      {}).freeze
    CurrentQuizzesLink = Link.new('Take Test',
      {:controller => '/students/quiz_attempt', :action => 'intro'},
      {:title => 'Sit enabled online test'},
      {}).freeze
    PreviewQuizzesLink = Link.new('Preview Tests',
      {:controller => '/students/preview_quiz', :action => 'intro'},
      {:title => 'Preview tests'},
      {}).freeze

    ManageSubjectsLink = Link.new('Manage Subjects',
      {:controller => '/administration/subjects', :action => 'list'},
      {:title => 'Add, edit or delete subjects'},
      {}).freeze
    ManageUsersLink = Link.new('Manage Users',
      {:controller => '/administration/users', :action => 'list'},
      {:title => 'Add or remove users'},
      {}).freeze
    ManageSubjectGroupsLink = Link.new('Manage Subject Groups',
      {:controller => '/administration/subject_group', :action => 'list' },
      {:title => 'Create, edit or delete subject groups'},
      {}).freeze
    ManageRoomsLink = Link.new('Manage Rooms',
      {:controller => '/administration/room', :action => 'list'},
      {:title => 'Create, edit or delete rooms'},
      {}).freeze
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
    link.name += current_user.username
    link
  end

  def gen_subject_link
    link = SubjectLink.dup
    link.name += current_subject.code
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
    if session[:role] == :student
      links << HomeLink
      links << gen_past_quizzes_link.freeze
      links << gen_current_quizzes_link.freeze
      links << gen_preview_quizzes_link.freeze
    elsif session[:role] == :teacher
      links << gen_manage_quizzes_link.freeze
      links << gen_manage_questions_link.freeze
    elsif session[:role] == :administrator
      links << gen_manage_subjects_link.freeze
      links << gen_manage_users_link.freeze
      links << gen_manage_subject_groups_link.freeze
      links << gen_manage_rooms_link.freeze
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

  def gen_past_quizzes_link
    is_selected = get_controller_name == '/students/results' && @action_name == 'statistics'
    dup_link_with_select( PastQuizzesLink, is_selected )
  end

  def gen_current_quizzes_link
    is_selected = get_controller_name == '/students/quiz_attempt' && @action_name == 'intro'
    dup_link_with_select( CurrentQuizzesLink, is_selected )
  end

  def gen_preview_quizzes_link
    is_selected = get_controller_name == '/students/preview_quiz' && @action_name == 'intro'
    dup_link_with_select( PreviewQuizzesLink, is_selected )
  end

  def gen_manage_quizzes_link
    is_selected = get_controller_name == '/teachers/quizzes' && @action_name == 'list'
    dup_link_with_select( ManageQuizzesLink, is_selected )
  end

   def gen_manage_questions_link
    is_selected = get_controller_name == '/teachers/question' && @action_name == 'list'
    dup_link_with_select( ManageQuestionsLink, is_selected )
  end

   def gen_manage_subjects_link
    is_selected = get_controller_name == '/administration/subjects' && @action_name == 'list'
    dup_link_with_select( ManageSubjectsLink, is_selected )
  end

  def gen_manage_users_link
    is_selected = get_controller_name == '/administration/users' && @action_name == 'list'
    dup_link_with_select( ManageUsersLink, is_selected )
  end
  
   def gen_manage_subject_groups_link
    is_selected = get_controller_name == '/administration/subject_group' && @action_name == 'list'
    dup_link_with_select( ManageSubjectGroupsLink, is_selected )
  end
  
  def gen_manage_rooms_link
    is_selected = get_controller_name == '/administration/room' && @action_name == 'list'
    dup_link_with_select( ManageRoomsLink, is_selected )
  end
end

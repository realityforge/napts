module SubjectSystem

protected
  def current_subject_id
    session[:subject_id]
  end

  def current_subject
    @current_subject = Subject.find(current_subject_id) unless @current_subject
    @current_subject
  end
end

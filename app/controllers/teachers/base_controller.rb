class Teachers::BaseController < ApplicationController
protected 
   def verify_access; verify_teacher; end
  include SubjectSystem

private
  def verify_teacher
    raise Napts::SecurityError unless current_user.educates_for?(current_subject_id)
  end
end

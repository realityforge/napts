class Teachers::BaseController < ApplicationController
  before_filter :verify_teacher

private
  def verify_teacher
    raise Napts::SecurityError unless current_user.teaches?(current_subject_id)
  end
end

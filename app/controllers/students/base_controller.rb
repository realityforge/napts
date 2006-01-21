class Students::BaseController < ApplicationController
  before_filter :verify_student

private
  def verify_student
    raise Napts::SecurityError unless session[:role] == :student
  end
end

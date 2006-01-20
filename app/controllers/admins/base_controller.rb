class Admins::BaseController < ApplicationController
  before_filter( :verify_admin )

private
  def verify_admin
    raise Napts::SecurityError unless current_user.administrator?
  end
end

class Demonstrators::BaseController < ApplicationController
  before_filter :verify_demonstrator

private
  def verify_demonstrator
    raise Napts::SecurityError unless current_user.demonstrator_for?(current_subject_id)
  end
end

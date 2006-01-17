class Demonstrators::BaseController < ApplicationController
protected
  def verify_access; verify_demonstrator; end
end

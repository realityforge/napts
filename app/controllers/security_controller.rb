class SecurityController < ApplicationController
  def access_denied
    # TODO log, or notify admin, or something like that
    # This place can only be acheivable by doing something wrong 
    # for now, go straight to template
  end
end

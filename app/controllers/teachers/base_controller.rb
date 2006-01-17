class Teachers::BaseController < ApplicationController
protected 
   def verify_access; verify_teacher; end
end

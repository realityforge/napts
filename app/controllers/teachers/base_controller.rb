class Teachers::BaseController < ApplicationController
  before_filter( :verify_teacher )
end

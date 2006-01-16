class Administration::BaseController < ApplicationController
  before_filter( :verify_admin )
end

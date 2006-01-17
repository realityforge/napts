class Demonstrators::BaseController < ApplicationController
  before_filter( :verify_demonstrator )
end

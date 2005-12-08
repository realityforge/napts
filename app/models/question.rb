class Question < ActiveRecord::Base
  validates_presence_of( :content )
  has_many( :answers, :dependent => true )
  
end

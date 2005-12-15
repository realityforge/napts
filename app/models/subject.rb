class Subject < ActiveRecord::Base
  has_many( :quizzes, :dependent => true )
end

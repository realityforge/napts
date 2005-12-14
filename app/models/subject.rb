class Subject < ActiveRecord::Base
  has_many( :quizzes )
end

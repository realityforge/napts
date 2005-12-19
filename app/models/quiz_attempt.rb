class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses )
end

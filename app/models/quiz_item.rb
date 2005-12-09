class QuizItem < ActiveRecord::Base
  validates_uniqueness_of( :question_id,
                           :scope => "quiz_id" )
  belongs_to( :question )
  belongs_to( :quiz )
end

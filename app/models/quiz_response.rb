class QuizResponse < ActiveRecord::Base
  belongs_to( :quiz_attempt )
  belongs_to( :question )
  has_and_belongs_to_many( :answers )
  validates_associated( :quiz_attempt, :question )
  validates_presence_of( :quiz_attempt_id, :question_id )
end

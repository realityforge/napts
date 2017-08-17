class QuizItem < ActiveRecord::Base
  validates_uniqueness_of( :question_id, :scope => 'quiz_id' )
  belongs_to( :question )
  belongs_to( :quiz )
  acts_as_list( :scope => :quiz_id )
  validates_presence_of( :quiz_id )
  validates_presence_of( :question_id )
  validates_presence_of( :position )
end

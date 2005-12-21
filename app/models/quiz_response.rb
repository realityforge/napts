class QuizResponse < ActiveRecord::Base
  belongs_to( :quiz_attempt )
  belongs_to( :question )
  has_and_belongs_to_many( :answers )
  acts_as_list( :scope => :quiz_attempt )
end

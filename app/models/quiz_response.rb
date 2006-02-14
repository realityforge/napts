class QuizResponse < ActiveRecord::Base
  belongs_to( :quiz_attempt )
  belongs_to( :question )
  has_and_belongs_to_many( :answers, :uniq => true )
  validates_presence_of( :quiz_attempt_id, :question_id )
  
  def correct?
    return true if self.question.corrected_at > self.updated_at
    if self.question.question_type == 1 || self.question.question_type == 2
      correct_answers = []
      for answer in self.question.answers
        correct_answers << answer.id if answer.is_correct
      end
      responses = []
      for response in self.answers
        responses << response.id
      end
      return responses.sort! == correct_answers.sort!
    elsif self.question.question_type == 3
      return self.input.strip.to_i == self.question.answers[0].content.to_i
    end
  end
end

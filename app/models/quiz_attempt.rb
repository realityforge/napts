class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses )
  
  def score
    results = []
    for quiz_response in self.quiz_responses
      responses = []
      correct = []
      for qr in quiz_response.answers
        responses << qr.answer_id.to_s
      end
      for question in quiz_response.question.answers
        correct << question.id.to_s if question.is_correct
      end
      if ! ( responses == correct )
        results << quiz_response.position.to_s
      end
    end
    return results
  end
end

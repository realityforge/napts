class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses, :order => :position, :dependent => true )
  
  # stores the question number of all the incorrect 
  # questions in an array and returns it
  def incorrect_answers
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
      correct.sort!
      responses.sort!
      if responses != correct
        results << quiz_response.position.to_s
      end
    end
    return results
  end
  
  def time_up?
    length = self.quiz.duration * 60
    number = ( now.to_i - self.start_time.to_i )
    return number > length
  end
  
  def get_response(position)
    return nil if position > self.quiz_responses.length 
    self.quiz_responses[position]
  end
  
private
  def now; Time.now; end  
end

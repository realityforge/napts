class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses, :order => 'position', :dependent => true, :include => ['answers', 'question'] )
  validates_presence_of( :created_at )
  validates_presence_of( :quiz_id )
  validates_presence_of( :user_id )

  def after_create
    quiz_items = self.quiz.quiz_items.find( :all, :conditions => ['is_on_test = ?', true] )
    if self.quiz.randomise?
      new_quiz_items = []
      for i in 0...quiz_items.length
      	new_quiz_items << quiz_items.delete_at( rand(quiz_items.length) )
      end
      quiz_items = new_quiz_items
    end
    count = 1
    for quiz_item in quiz_items
      self.quiz_responses.create(:completed => false,
                                 :question_id => quiz_item.question_id,
                                 :position => count )
      count += 1
    end
  end

  def next_response
    quiz_responses.find(:first, :conditions => ['completed = ?', false] )
  end

  def completed?
    not end_time.nil?
  end

  def complete
    update_attributes( :end_time => Time.now )
  end

  # Returns an array (of positions) of the incorrect answers
  def incorrect_answers
    results = []
    for quiz_response in self.quiz_responses
      responses = []
      correct = []
      for answer in quiz_response.answers
        responses << answer.id
      end
      for question in quiz_response.question.answers
        correct << question.id if question.is_correct
      end
      correct.sort!
      responses.sort!
      if responses != correct
        results << quiz_response.position
      end
    end
    return results
  end

  def time_up?(time)
    length = self.quiz.duration * 60
    number = ( time.to_i - self.created_at.to_i )
    return number > length
  end
end

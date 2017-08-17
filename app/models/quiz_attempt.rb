class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses, :order => 'quiz_responses.position', :dependent => true, :include => ['answers', 'question'] )
  validates_presence_of( :created_at )
  validates_presence_of( :quiz_id )
  validates_presence_of( :user_id )
  validates_presence_of( :computer )

  def after_create
    quiz_items = self.quiz.quiz_items.find( :all, :conditions => ['preview_only = ?', false] )
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
      if ! quiz_response.correct?
        results << quiz_response.position
      end
    end
    return results
  end

  def calculate_score
    if self.score.nil?
      num_questions = self.quiz_responses.size
      incorrect_questions = self.incorrect_answers.size
      score = num_questions - incorrect_questions
      self.update_attributes( :score => score )
    end
    return self.score
  end

  def time_up?(time)
    length = self.quiz.duration * 60
    number = ( time.to_i - self.created_at.to_i )
    return number > length
  end
end

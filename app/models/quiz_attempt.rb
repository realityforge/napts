class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses, :order => :position, :dependent => true, :include => ['answers', 'question'] )
  validates_presence_of( :created_at )
  validates_presence_of( :quiz_id )
  validates_presence_of( :user_id )
  validates_associated( :quiz )
  validates_associated( :user )

  def after_create
    quiz_items = self.quiz.quiz_items.find_all{ |x| x.is_on_test? }
    if self.quiz.randomise?
      quiz_items = quiz_items.sort{|a, b| rand(3)-1}.slice(0...quiz_items.length)
    end
    count = 1
    for quiz_item in quiz_items
      self.quiz_responses.create(:completed => false,
                                 :question_id => quiz_item.question.id,
                                 :position => count )
      count += count
    end
  end

  def next_response
    quiz_responses.find(:first, :conditions => ['completed = ?', false], :order => 'position' )
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

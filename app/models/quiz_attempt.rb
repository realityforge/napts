class QuizAttempt < ActiveRecord::Base
  belongs_to( :quiz )
  belongs_to( :user )
  has_many( :quiz_responses, :order => :position, :dependent => true, :include => ['answers', 'question'] )
  validates_presence_of( :start_time )
  validates_presence_of( :quiz_id )
  validates_presence_of( :user_id )
  validates_associated( :quiz )
  validates_associated( :user )

  def after_create
    count = 1
    for quiz_item in self.quiz.quiz_items
      if quiz_item.is_on_test?
        self.quiz_responses.create( :created_at => Time.now,
                                    :completed => false,
                                    :question_id => quiz_item.question.id,
                                    :position => count )
        count += count
      end
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

  # stores the question number of all the incorrect
  # questions in an array and returns it
  def incorrect_answers
    results = []
    for quiz_response in self.quiz_responses
      responses = []
      correct = []
      for answer in quiz_response.answers
        responses << answer.id.to_s
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

private
  def now; Time.now; end
end

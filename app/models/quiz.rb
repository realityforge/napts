class Quiz < ActiveRecord::Base
  has_many( :quiz_items, :dependent => true, :order => 'position' )
  has_many( :quiz_attempts, :dependent => true )
  has_and_belongs_to_many( :active_in, :class_name => 'Room', :join_table => 'quizzes_rooms' )
  belongs_to( :subject )
  validates_presence_of( :subject_id )
  validates_uniqueness_of( :name )
  validates_associated( :subject )
  validates_length_of( :name, :within => 1..20 )
  validates_length_of( :description, :within => 1..120 )
  validates_numericality_of( :duration )

  def quiz_attempt_for_user( user_id )
    quiz_attempt = QuizAttempt.find( :first, :conditions => ['user_id = ? AND quiz_id = ?', user_id, self.id ] )
    quiz_attempt = self.quiz_attempts.create!( :created_at => Time.now, :user_id => user_id ) unless quiz_attempt
    quiz_attempt
  end

  def user_completed?( user_id )
    quiz_attempt = QuizAttempt.find( :first, :conditions => ['user_id = ? AND quiz_id = ? AND end_time IS NOT NULL', user_id, self.id ] )
    return ! quiz_attempt.nil?
  end

  def address_active?( remote_ip )
    computer = Computer.find( :first,
                              :select => 'computers.*',
                              :joins =>
			      'LEFT OUTER JOIN quizzes ON quizzes.id = quizzes_rooms.quiz_id '+
			      'LEFT OUTER JOIN quizzes_rooms ON quizzes_rooms.room_id = computers.room_id',
                              :conditions => ['computers.ip_address = ? AND quizzes.id = ?', remote_ip, self.id ] )
    return ! computer.nil?
  end
  
  def completed_attempts?
    QuizAttempt.count(['quiz_id = ? AND end_time IS NOT NULL', self.id])
  end
  
  def active_attempts?
    QuizAttempt.count(['quiz_id = ? AND end_time IS NULL', self.id])
  end

  def validate
    errors.add( :duration, "should be positive" ) unless duration > 0
  end
end

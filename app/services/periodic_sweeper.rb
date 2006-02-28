class PeriodicSweeper 

  def self.sweep
    PeriodicSweeper.update_quiz_attempts
    PeriodicSweeper.remove_stale_sessions
  end

  def self.update_quiz_attempts
    # Finishes any timed out quizzes
    QuizAttempt.find(:all).each {|a| a.complete if a.time_up?(Time.now)} 
    
    # Scores all unscored but completed quizzes
    quiz_attempts =
      QuizAttempt.find(:all, 
                       :conditions => 'score IS NULL AND end_time IS NOT NULL')
    quiz_attempts.each {|a|a.calculate_score}
  end
  
  def self.remove_stale_sessions
    CGI::Session::ActiveRecordStore::Session.destroy_all( ['updated_on <?', 20.minutes.ago] ) 
  end
end

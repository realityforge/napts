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
    # Max idle time for session in seconds
    max_session_time = 60 * 20
    
    CGI::Session::ActiveRecordStore::Session.find(:all,
                                                  :conditions => ['updated_on <?', (Time.now - max_session_time)]
                                                  ).each { |s| s.destroy }
  end
end

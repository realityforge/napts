class SessionCleaner
  # Max idle time for session in seconds
  @@max_session_time = 60 * 20

  def self.remove_stale_sessions
    CGI::Session::ActiveRecordStore::Session.find(:all,
                                                  :conditions => ['updated_on <?', (Time.now - @@max_session_time)]
                                                  ).each do |session|
      session.destroy
    end
  end
end

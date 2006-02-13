class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    STDERR.puts('Creating initial schema')
    # Sessions
    create_table('sessions', :force => true) do |t|
      t.column 'sessid', :string, :limit => 32, :null => false
      t.column 'data', :text
      t.column 'created_on', :timestamp
      t.column 'updated_on', :timestamp
    end
    add_index('sessions', ['sessid'], :name => 'sessions_sessid_index')
    
    # Users
    create_table('users', :force => true) do |t|
      t.column 'name', :string, :limit => 25, :null => false
      t.column 'administrator', :boolean, :null => false
    end
    add_index('users', ['name'], :name => 'users_name_index', :unique => true)
    
    # Rooms
    create_table('rooms', :force => true) do |t|
      t.column 'name', :string, :limit => 50, :null => false
    end
    add_index('rooms', ['name'], :name => 'rooms_name_index', :unique => true)
    
    # Computers
    create_table('computers', :force => true) do |t|
      t.column 'ip_address', :string, :limit => 16, :null => false
      t.column 'room_id', :integer, :null => false
    end
    add_index('computers', ['id', 'room_id'], :name => 'computers_ip_room_id_index', :unique => true)
    add_foreign_key_constraint('computers', 'room_id', 'rooms', 'id', :name => 'computers_room_id_fk')
    
    # SubjectGroups
    create_table('subject_groups', :force => true) do |t|
      t.column 'name', :string, :limit => 50, :null => false
    end
    
    # Subjects
    create_table('subjects', :force => true) do |t|
      t.column 'name', :string, :limit => 10, :null => false
      t.column 'subject_group_id', :integer, :null => false
    end
    add_index('subjects', ['name'], 
              :name => 'subjects_name_index', 
	      :unique => true)
    add_index('subjects', ['name', 'subject_group_id'], :name => 'subjects_name_subject_group_index', :unique => true )
    add_foreign_key_constraint('subjects', 'subject_group_id', 'subject_groups', 'id', :name => 'subjects_subject_group_id_fk')
    
    # Quizzes
    create_table('quizzes', :force => true) do |t|
      t.column 'name', :string, :limit => 20, :null => false
      t.column 'description', :text, :limit => 120, :null => false
      t.column 'duration', :integer, :null => false
      t.column 'randomise', :boolean, :null => false
      t.column 'subject_id', :integer, :null => false
      t.column 'created_at', :datetime
      t.column 'publish_results', :boolean, :null => false
      t.column 'preview_enabled', :boolean, :null => false
    end
    add_index('quizzes', ['name', 'subject_id'], 
              :name => 'quizzes_name_subject_id_index', 
	      :unique => true)
    add_foreign_key_constraint('quizzes', 'subject_id', 'subjects', 'id', :name => 'quizzes_subject_id_fk')    

    # QuizAttempts
    create_table('quiz_attempts', :force => true) do |t|
      t.column 'created_at', :datetime, :null => false
      t.column 'end_time', :datetime
     
      t.column 'quiz_id', :integer, :null => false
      t.column 'user_id', :integer, :null => false
    end
    add_index('quiz_attempts', ['id', 'quiz_id'], :name => 'quiz_attempts_id_quiz_id_index', :unique => true)
    add_foreign_key_constraint('quiz_attempts', 'quiz_id', 'quizzes', 'id', :name => 'quiz_attempts_quiz_id_fk')
    add_foreign_key_constraint('quiz_attempts', 'user_id', 'users', 'id', :name => 'quiz_attempts_user_id_fk')

    # Questions
    create_table('questions', :force => true) do |t|
      t.column 'content', :text, :null => false
      t.column 'question_type', :integer, :null => false
      t.column 'subject_group_id', :integer, :null => false
    end
    add_index('questions', ['id', 'subject_group_id'], :name => 'questions_subject_groups', :unique => true )
    add_foreign_key_constraint('questions', 'subject_group_id', 'subject_groups', 'id', :name => 'questions_subject_group_id_fk')

    # QuizItems
    create_table('quiz_items', :force => true) do |t|
      t.column 'preview_only', :boolean, :null => false
      t.column 'quiz_id', :integer, :null => false
      t.column 'question_id', :integer, :null => false
      t.column 'position', :integer, :null => false
    end
    add_index('quiz_items', ['id', 'quiz_id'], :name => 'quiz_items_id_quiz_id_index', :unique => true)
    add_foreign_key_constraint('quiz_items', 'quiz_id', 'quizzes', 'id', :name => 'quiz_items_quiz_id_fk')
    add_foreign_key_constraint('quiz_items', 'question_id', 'questions', 'id', :name => 'quiz_items_question_id_fk')

    # Answers
    create_table('answers', :force => true) do |t|
      t.column 'content', :text, :null => false
      t.column 'is_correct', :boolean
      t.column 'question_id', :integer, :null => false
    end
    add_index('answers', ['id', 'question_id'], :name => 'answers_content_question_id_index', :unique => true)
    add_foreign_key_constraint('answers', 'question_id', 'questions', 'id',
                               :name => 'answers_question_id_fk')
    
    # Resources
    create_table('resources', :force => true) do |t|
      t.column 'name', :string, :limit => 50, :null => false
      t.column 'description', :text, :limit => 120
      t.column 'content_type', :string, :limit => 25, :null => false
      t.column 'subject_group_id', :integer, :null => false
    end
    add_index('resources', ['name', 'subject_group_id'], :name => 'resources_subeject_groups', :unique => true )
    add_foreign_key_constraint('resources', 'subject_group_id', 'subject_groups', 'id',
                               :name => 'resource_subject_group_id_fk')
   
    #ResourceData
    create_table('resource_data', :force => true) do |t|
      t.column 'data', :binary, :null => false
      t.column 'resource_id', :integer, :null => false
    end
    add_foreign_key_constraint('resource_data', 'resource_id', 'resources', 'id',
                               :name => 'resource_data_resource_id_fk')

    #Questions_Resources
    create_table('questions_resources', :id => false, :force => true) do |t|
      t.column 'question_id', :integer, :null => false
      t.column 'resource_id', :integer, :null => false
    end
    add_index('questions_resources', ['question_id', 'resource_id'], :name => 'questions_resources_id_index', :unique => true )
    add_foreign_key_constraint('questions_resources', 'question_id', 'questions', 'id',
                               :name => 'question_id_fk')
    add_foreign_key_constraint('questions_resources', 'resource_id', 'resources', 'id',
                               :name => 'resource_id_fk')
    
    # QuizResponses
    create_table('quiz_responses', :force => true) do |t|
      t.column 'input', :string, :limit => 125
      t.column 'updated_at', :datetime
      t.column 'position', :integer
      t.column 'completed', :boolean, :null => false
      t.column 'quiz_attempt_id', :integer, :null => false
      t.column 'question_id', :integer, :null => false
    end
    add_index('quiz_responses', ['id', 'quiz_attempt_id'], :name => 'quiz_responses_id_quiz_attempt_id_index', :unique => true)
    add_foreign_key_constraint('quiz_responses', 'quiz_attempt_id', 'quiz_attempts', 'id', 
                               :name => 'quiz_responses_quiz_attempt_id_fk')
    add_foreign_key_constraint('quiz_responses', 'question_id', 'questions', 'id', 
                               :name => 'quiz_responses_question_id_fk')
         
    # Answers_QuizResponses
    create_table('answers_quiz_responses', :id => false, :force => true ) do |t|
      t.column 'quiz_response_id', :integer, :null => false
      t.column 'answer_id', :integer, :null => false
    end
    add_index('answers_quiz_responses', ['quiz_response_id', 'answer_id'],
              :name => 'answers_quiz_responses_id_index', :unique => true )
    add_foreign_key_constraint('answers_quiz_responses', 'quiz_response_id', 'quiz_responses', 'id',
                               :name => 'quiz_response_id_fk')
    add_foreign_key_constraint('answers_quiz_responses', 'answer_id', 'answers', 'id',
                               :name => 'answer_id_fk')
    
    #Demonstrators
    create_table('demonstrators', :id => false, :force => true ) do |t|
      t.column 'subject_id', :integer, :null => false
      t.column 'user_id', :integer, :null => false
    end
    add_foreign_key_constraint('demonstrators', 'subject_id', 'subjects', 'id',
                               :name => 'demonstrators_subject_id_fk')
    add_foreign_key_constraint('demonstrators', 'user_id', 'users', 'id',
                               :name => 'demonstrators_user_id_fk')
    add_index('demonstrators', ['subject_id', 'user_id'],
              :name => 'demonstrators_subject_id_user_id_index',
	      :unique => true)
    
    #Teachers
    create_table('teachers', :id => false, :force => true ) do |t|
      t.column 'subject_id', :integer, :null => false
      t.column 'user_id', :integer, :null => false
    end
    add_foreign_key_constraint('teachers', 'subject_id', 'subjects', 'id',
                               :name => 'teachers_subject_id_fk')
    add_foreign_key_constraint('teachers', 'user_id', 'users', 'id',
                               :name => 'teachers_user_id_fk')
    add_index('teachers', ['subject_id', 'user_id'],
              :name => 'teachers_subject_id_user_id_index',
	      :unique => true)
    
    #Students
    create_table('students', :id => false, :force => true ) do |t|
      t.column 'subject_id', :integer, :null => false
      t.column 'user_id', :integer, :null => false
    end
    add_foreign_key_constraint('students', 'subject_id', 'subjects', 'id',
                               :name => 'students_subject_id_fk')
    add_foreign_key_constraint('students', 'user_id', 'users', 'id',
                               :name => 'students_user_id_fk')
    add_index('students', ['subject_id', 'user_id'], 
              :name => 'students_subject_id_user_id_index',
	      :unique => true)
    
    #Quizzes_Rooms
    create_table('quizzes_rooms', :id => false, :force => true ) do |t|
      t.column 'quiz_id', :integer, :null => false
      t.column 'room_id', :integer, :null => false
    end
    add_foreign_key_constraint('quizzes_rooms', 'quiz_id', 'quizzes', 'id', :name => 'quiz_id_fk' )
    add_foreign_key_constraint('quizzes_rooms', 'room_id', 'rooms', 'id', :name => 'room_id_fk' )
  end
  
  def self.down
    drop_table('questions_resources')
    drop_table('resource_data')
    drop_table('resources')
    drop_table('quizzes_rooms')
    drop_table('students')
    drop_table('teachers')
    drop_table('demonstrators')
    drop_table('answers_quiz_responses')
    drop_table('quiz_responses')
    drop_table('resources')
    drop_table('answers')
    drop_table('quiz_items')
    drop_table('questions')
    drop_table('quiz_attempts')
    drop_table('quizzes')
    drop_table('subjects')
    drop_table('subject_groups')
    drop_table('computers')
    drop_table('rooms')
    drop_table('users')
    drop_table('sessions')
  end
end

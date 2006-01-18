class CreateInitialSchema < ActiveRecord::Migration
  def self.up
    STDERR.puts("Creating initial schema")
    # Sessions
    create_table("sessions", :force => true) do |t|
      t.column "sessid", :string, :limit => 32, :null => false
      t.column "data", :text
      t.column "created_on", :timestamp
      t.column "updated_on", :timestamp
    end
    add_index("sessions", ["sessid"], :name => "sessions_sessid_index")
    
    # Users
    create_table("users", :force => true) do |t|
      t.column "username", :string, :limit => 25, :null => false
      t.column "administrator", :boolean, :null => false
      t.column "name", :string, :limit => 50, :null => false
      t.column "hashed_password", :string, :limit => 50, :null => false
    end
    add_index("users", ["username"], :name => "users_username_index", :unique => true)
    
    # Rooms
    create_table("rooms", :force => true) do |t|
      t.column "name", :string, :limit => 50, :null => false
    end
    add_index("rooms", ["name"], :name => "rooms_name_index", :unique => true)
    
    # Computers
    create_table("computers", :force => true) do |t|
      t.column "ip_address", :string, :limit => 16, :null => false
      t.column "room_id", :integer, :null => false
    end
    add_foreign_key_constraint("computers", "room_id", "rooms", "id", :name => "computers_room_id_fk")
    
    # SubjectGroups
    create_table("subject_groups", :force => true) do |t|
      t.column "name", :string, :limit => 50, :null => false
    end
    
    # Subjects
    create_table("subjects", :force => true) do |t|
      t.column "code", :string, :limit => 10, :null => false
      t.column "subject_group_id", :integer, :null => false
    end
    add_index("subjects", ["code"], :name => "subjects_code_index", :unique => true)
    add_foreign_key_constraint("subjects", "subject_group_id", "subject_groups", "id", :name => "subjects_subject_group_id_fk")
    
    # Quizzes
    create_table("quizzes", :force => true) do |t|
      t.column "name", :string, :limit => 20, :null => false
      t.column "description", :text, :limit => 120, :null => false
      t.column "duration", :integer, :null => false
      t.column "subject_id", :integer, :null => false
      t.column "enable", :boolean, :null => false
      t.column "prelim_enable", :boolean, :null => false
    end
    add_index("quizzes", ["name", "subject_id"], :name => "quizzes_name_subject_id_index", :unique => true)
    add_foreign_key_constraint("quizzes", "subject_id", "subjects", "id", :name => "quizzes_subject_id_fk")    

    # QuizAttempts
    create_table("quiz_attempts", :force => true) do |t|
      t.column "start_time", :datetime, :null => false
      t.column "end_time", :datetime
 #     t.column "computer_id", :integer, :null => false
      t.column "quiz_id", :integer, :null => false
      t.column "user_id", :integer, :null => false
    end
#    add_foreign_key_constraint("quiz_attempts", "computer_id", "computers", "id", :name => "quiz_attempts_computer_id_fk")
    add_foreign_key_constraint("quiz_attempts", "quiz_id", "quizzes", "id", :name => "quiz_attempts_quiz_id_fk")
    add_foreign_key_constraint("quiz_attempts", "user_id", "users", "id", :name => "quiz_attempts_user_id_fk")

    # Questions
    create_table("questions", :force => true) do |t|
      t.column "content", :text, :null => false
      t.column "question_type", :integer, :null => false
      t.column "subject_group_id", :integer, :null => false
    end
    add_foreign_key_constraint( "questions", "subject_group_id", "subject_groups", "id", :name => "questions_subject_group_id_fk")

    # QuizItems
    create_table("quiz_items", :force => true) do |t|
      t.column "is_on_test", :boolean, :null => false
      t.column "quiz_id", :integer, :null => false
      t.column "question_id", :integer, :null => false
      t.column "position", :integer, :null => false
    end
    add_foreign_key_constraint("quiz_items", "quiz_id", "quizzes", "id", :name => "quiz_items_quiz_id_fk")
    add_foreign_key_constraint("quiz_items", "question_id", "questions", "id", :name => "quiz_items_question_id_fk")

    # Answers
    create_table("answers", :force => true) do |t|
      t.column "content", :text, :null => false
      t.column "is_correct", :boolean
      t.column "question_id", :integer, :null => false
    end
    add_foreign_key_constraint("answers", "question_id", "questions", "id", :name => "answers_question_id_fk")
    
    # Resources
    create_table("resources", :force => true) do |t|
      t.column "type", :string, :limit => 25, :null => false
      t.column "resource", :string, :limit => 125, :null => false
      t.column "question_id", :integer, :null => false
    end
    add_foreign_key_constraint("resources", "question_id", "questions", "id", 
                               :name => "resources_iquestion_id_fk")

    # QuizResponses
    create_table("quiz_responses", :force => true) do |t|
      t.column "input", :string, :limit => 125
      t.column "created_at", :datetime
      t.column "position", :integer
      t.column "quiz_attempt_id", :integer, :null => false
      t.column "question_id", :integer, :null => false
    end
    add_foreign_key_constraint("quiz_responses", "quiz_attempt_id", "quiz_attempts", "id", 
                               :name => "quiz_responses_quiz_attempt_id_fk")
    add_foreign_key_constraint("quiz_responses", "question_id", "questions", "id", 
                               :name => "quiz_responses_question_id_fk")
  
    # Answers_QuizResponses
    create_table("answers_quiz_responses", :id => false, :force => true ) do |t|
      t.column "quiz_response_id", :integer, :null => false
      t.column "answer_id", :integer, :null => false
    end
    add_foreign_key_constraint("answers_quiz_responses", "quiz_response_id", "quiz_responses", "id",
                                :name => "quiz_response_id_fk")
    add_foreign_key_constraint("answers_quiz_responses", "answer_id", "answers", "id",
    				:name => "answer_id_fk")
    
    #Demonstrators
    create_table("demonstrators", :id => false, :force => true ) do |t|
      t.column "subject_id", :integer, :null => false
      t.column "user_id", :integer, :null => false
    end
    add_foreign_key_constraint("demonstrators", "subject_id", "subjects", "id",
                                :name => "demonstrators_subject_id_fk")
    add_foreign_key_constraint("demonstrators", "user_id", "users", "id",
                                :name => "demonstrators_user_id_fk")
     add_index("demonstrators", ["subject_id", "user_id"], :name => "demonstrators_subject_id_user_id_index", :unique => true)
    
    #Teachers
    create_table("teachers", :id => false, :force => true ) do |t|
      t.column "subject_id", :integer, :null => false
      t.column "user_id", :integer, :null => false
    end
    add_foreign_key_constraint("teachers", "subject_id", "subjects", "id",
                                :name => "eteachers_subject_id_fk")
    add_foreign_key_constraint("teachers", "user_id", "users", "id",
                                :name => "teachers_user_id_fk")
     add_index("teachers", ["subject_id", "user_id"], :name => "teachers_subject_id_user_id_index", :unique => true)
  end
  
  def self.down
    drop_table("teachers")
    drop_table("demonstrators")
    drop_table("answers_quiz_responses")
    drop_table("quiz_responses")
    drop_table("resources")
    drop_table("answers")
    drop_table("quiz_items")
    drop_table("questions")
    drop_table("quiz_attempts")
    drop_table("quizzes")
    drop_table("subjects")
    drop_table("subject_groups")
    drop_table("computers")
    drop_table("rooms")
    drop_table("users")
    drop_table("sessions")
  end
end

class Subject < ActiveRecord::Base
  belongs_to( :subject_group )
  has_many( :quizzes, :dependent => true )
  has_and_belongs_to_many( :demonstrators, :class_name => "User", :join_table => "demonstrators" )
  has_and_belongs_to_many( :teachers, :class_name => "User", :join_table => "teachers" )
end

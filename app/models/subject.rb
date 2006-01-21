class Subject < ActiveRecord::Base
  belongs_to( :subject_group )
  has_many( :quizzes, :dependent => true )
  has_and_belongs_to_many( :demonstrators, :class_name => "User", :join_table => "demonstrators" )
  has_and_belongs_to_many( :teachers, :class_name => "User", :join_table => "teachers" )
  validates_uniqueness_of( :code )
  validates_length_of( :code, :within => 1..10 )
  validates_associated( :subject_group )
  validates_presence_of( :subject_group_id )

  # Can not modify subject group unless willing to clone all associated quizzes
  # and questions from old subject group into new subject group
  attr_accessible( :code )
end

class Subject < ActiveRecord::Base
  # Can not modify subject group unless willing to clone all associated quizzes
  # and questions from old subject group into new subject group
  belongs_to( :subject_group )
  has_many( :quizzes, :dependent => true )
  has_and_belongs_to_many( :demonstrators, :class_name => 'User', :join_table => 'demonstrators', :uniq => true, :order => 'username' )
  has_and_belongs_to_many( :teachers, :class_name => 'User', :join_table => 'teachers', :uniq => true, :order => 'username' )
  validates_uniqueness_of( :name )
  validates_length_of( :name, :within => 1..10 )
  validates_associated( :subject_group )
  validates_presence_of( :subject_group_id )

  def self.find_all_sorted
    find(:all, :order => 'name')
  end
end

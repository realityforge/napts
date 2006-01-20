class SubjectGroup < ActiveRecord::Base
  has_many( :subjects, :dependent => true )
  has_many( :questions, :dependent => true )
  validates_length_of( :name, :within => 1..50 )
  validates_uniqueness_of( :name )

  def self.find_all_sorted
    find(:all, :order => 'name')
  end
end

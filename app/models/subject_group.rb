class SubjectGroup < ActiveRecord::Base
  has_many( :subjects, :dependent => true )
  has_many( :questions, :dependent => true )
end

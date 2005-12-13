class Quiz < ActiveRecord::Base
  has_many( :quiz_items )
  belongs_to( :subjects )
end

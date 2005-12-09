class Quiz < ActiveRecord::Base
  has_many( :quiz_items )
end

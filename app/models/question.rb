class Question < ActiveRecord::Base
  validates_presence_of( :content )
  has_many( :answers, :dependent => true )
  has_many( :quiz_items )
  
  QUESTION_TYPE = {
    "Multiple answers" => 1,
    "Single answer" => 2
  }.freeze
 
  def validate
    count = 0
    self.answers.each { |x| count += 1 if x.is_correct? } 
    if question_type == 2 && count > 1
      errors.add_to_base( "Must have a single correct answer" )
    end
  end
end

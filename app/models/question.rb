class Question < ActiveRecord::Base
  validates_presence_of( :content )
  validates_presence_of( :question_type )
  validates_presence_of( :subject_group_id )
  has_many( :answers, :dependent => true )
  has_many( :quiz_items )
  has_many( :quiz_responses )
  has_and_belongs_to_many( :resources )
  belongs_to( :subject_group )
  validates_associated( :subject_group )
  
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
  
  def has_resource?
    self.resources.size > 0
  end
end

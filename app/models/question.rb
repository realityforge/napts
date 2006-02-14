class Question < ActiveRecord::Base
  validates_presence_of( :content )
  validates_presence_of( :question_type )
  validates_presence_of( :subject_group_id )
  validates_presence_of( :corrected_at )
  has_many( :answers, :dependent => true, :order => 'position' )
  has_many( :quiz_items )
  has_many( :quiz_responses )
  has_and_belongs_to_many( :resources, :uniq => true )
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
  
  def randomise_answers
    answers = self.answers
    new_answers = []
    for i in 0...answers.length
      new_answers << answers.delete_at( rand(answers.length) )
    end
    count = 1
    for answer in new_answers
      answer.update_attributes( :position => count )
      count += 1
    end
  end
  
  def has_resource?
    self.resources.size > 0
  end
end

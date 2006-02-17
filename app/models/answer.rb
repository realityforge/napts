class Answer < ActiveRecord::Base
  validates_length_of( :content, :minimum => 1 )
  belongs_to( :question )
  has_and_belongs_to_many( :quiz_responses, :uniq => true )
  acts_as_list( :scope => :question_id )
  
  def formatted_content
    TextFormatter.formatted_content(question.text_format,content)
  end
end

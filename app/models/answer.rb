class Answer < ActiveRecord::Base
  validates_length_of( :content, :minimum => 1 )
  belongs_to( :question )
  has_and_belongs_to_many( :quiz_responses, :uniq => true )
  acts_as_list( :scope => :question_id )
  
  def formatted_content
    if self.question.text_format == Question::RedClothFormat
      RedCloth.new( content ).to_html
    elsif self.question.text_format == Question::BlueClothFormat
      BlueCloth::new( content ).to_html
    elsif self.question.text_format == Question::RubyPantsFormat
      RubyPants.new( content ).to_html
    else #assume PlainFormat
      content
    end
  end
end

class Question < ActiveRecord::Base
  validates_presence_of( :content )
  validates_presence_of( :question_type )
  validates_presence_of( :subject_group_id )
  validates_presence_of( :corrected_at )
  validates_presence_of( :text_format )
  has_many( :answers, :dependent => true, :order => 'position' )
  has_many( :quiz_items )
  has_many( :quiz_responses )
  has_and_belongs_to_many( :resources, :uniq => true )
  belongs_to( :subject_group )
  validates_associated( :subject_group )

  MultiOptionType = 1
  SingleOptionType = 2
  NumberType = 3
  TextType = 4

  QUESTION_TYPE = {
    "Multiple answers" => MultiOptionType,
    "Single answer" => SingleOptionType,
    "Number" => NumberType,
    "Text" => TextType
  }.freeze
  
  TEXT_FORMAT = {
    "RedCloth" => 1,
    "BlueCloth" => 2,
    "RubyPants" => 3,
    "Plain" => 4
  }.freeze
  
  def validate
    if (question_type == MultiOptionType || question_type == SingleOptionType) && @choices
      correct_count = 0
      choices.each_value do |choice|
        errors.add_to_base( 'All answers must have content of length 1 or more.' ) if (! choice[:content] || choice[:content].length == 0)
        correct_count += 1 if choice[:is_correct].to_s == 'true'
      end
      errors.add_to_base( 'Must select single correct answer.' ) if (question_type == SingleOptionType && correct_count != 1)
    elsif question_type == NumberType && @number_answer
      errors.add_to_base( 'Must specify a number answer.' ) if (! number_answer || !(number_answer.to_s =~ /^[+-]?\d+$/))
    elsif question_type == TextType && @text_answer
      errors.add_to_base( 'Must have a answer of length of 1 or more.' ) if (! text_answer || text_answer.length == 0)
    end
  end
  
  def get_answers
    answers = self.answers
    if self.randomise?
      new_answers = []
      for i in 0...answers.length
        new_answers << answers.delete_at( rand(answers.length) )
      end
      answers = new_answers
    end
    return answers
  end
  
  def has_resource?
    self.resources.size > 0
  end

  def text_answer
    @text_answer = (question_type == TextType) ? answers[0].content : '' unless @text_answer
    @text_answer
  end

  def text_answer=(value)
    @text_answer = value
  end

  def number_answer
    @number_answer = (question_type == NumberType) ? answers[0].content : '' unless @number_answer
    @number_answer
  end

  def number_answer=(value)
    @number_answer = value
  end

  def choices
    if ! @choices
      @choices = {}
      if question_type == MultiOptionType || question_type == SingleOptionType
        self.answers.each do |answer|
          choices[answer.id.to_s] = {:content => answer.content, :position => answer.position, :is_correct => answer.is_correct}
        end
      end
    end
    @choices
  end

  def choices=(value)
    @choices = value
  end

  def after_save
    if question_type == NumberType && @number_answer
      answers.clear
      Answer.create!(:question_id => id, :content => @number_answer, :position => 1, :is_correct => true)
    elsif question_type == TextType && @text_answer
      answers.clear
      Answer.create!(:question_id => id, :content => @text_answer, :position => 1, :is_correct => true)
    elsif (question_type == MultiOptionType || question_type = SingleOptionType) && @choices
      answers.clear
      @choices.each_value do |choice|
        Answer.create!(:question_id => id, :content => choice[:content], :position => choice[:position], :is_correct => choice[:is_correct])
      end
    end
  end
end

require 'rexml/document'

class Importer

  def self.import_file(subject_name,file_name)
    subject = Subject.find_by_name(subject_name)
    raise "Unknown subject #{subject_name}" unless subject
    raise "Missing file #{file_name}" unless FileTest.exists?(file_name)
    f = File.new(file_name)
    testset = REXML::Document.new(f).root
    f.close
    Quiz.transaction do
      testset.elements.each('TEST') {|test| Importer.import_test(subject,test)}
    end
  end

  def self.import_test(subject,test)
    desc = test.elements.to_a[0]
    name = (desc.attributes['SUBJECT'] + '-' + desc.attributes['NAME']).slice(0,20)
    STDERR.puts "Importing test #{name}" unless ENV['RAILS_ENV'] == 'test'
    quiz = Quiz.create!(:name => name, 
                        :description => "Imported from #{name}".slice(0,120),
                        :duration => 10,
                        :randomise => true,
                        :subject_id => subject.id,
                        :created_at => Time.now,
                        :publish_results => false,
                        :preview_enabled => false)
    test.elements.each('TASK') {|task| Importer.import_question(quiz,task)}
  end

  def self.import_question(quiz,task)
    content = "<div>#{CGI::unescapeHTML(task.elements['DESCRIPTION'].text || '')}</div><div>#{CGI::unescapeHTML(task.elements['QUESTION'].text || '')}</div>"
    choices = task.elements['SINGLE-CHOICE']
    if choices
      type = Question::SingleOptionType
    else
      choices = task.elements['MULTI-CHOICE']
      word = ''
      if choices
        type = Question::MultiOptionType
      else
	if task.elements['WORD']
	  word = task.elements['WORD'].attributes['CORRECT']
	  type = Question::TextType
	elsif task.elements['NUMBER']
	  number = task.elements['NUMBER'].attributes['CORRECT']
	  type = Question::NumberType
	end
      end
    end
    question = Question.create!(:content => content, 
                                :subject_group_id => quiz.subject.subject_group_id,
                                :question_type => type,
                                :randomise => true,
				:text_format => TextFormatter::PlainFormat,
                                :corrected_at => Time.now)

    quiz.quiz_items.create(:preview_only => false, :question_id => question.id)
    if type == Question::MultiOptionType || type == Question::SingleOptionType 
      choices.elements.each('OPTION') do |option| 
        Answer.create!(:question_id => question.id, :content => CGI::unescapeHTML(option.text || ''), :is_correct => (option.attributes['CORRECT'] == 'true'))
      end
    elsif type == Question::NumberType
      Answer.create!(:question_id => question.id, :content => number, :position => 1, :is_correct => true)
    else # type == Question::TextType
      Answer.create!(:question_id => question.id, :content => "^#{word}$", :position => 1, :is_correct => true)
    end
  end
end

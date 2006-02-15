require "rexml/document"

class Importer

  def self.import_file(subject_name,file_name)
    subject = Subject.find_by_name(subject_name)
    testset = REXML::Document.new(File.new(file_name)).root
    Quiz.transaction do
      testset.elements.each('TEST') {|test| Importer.import_test(subject,test)}
    end
  end

  def self.import_test(subject,test)
    desc = test.elements.to_a[0]
    name = (desc.attributes['SUBJECT'] + '-' + desc.attributes['NAME']).slice(0,20)
    STDERR.puts "Importing test #{name}"
    quiz = Quiz.create!(:name => name, 
                        :description => "imported from #{name}".slice(0,120),
                        :duration => 10,
                        :randomise => true,
                        :subject_id => subject.id,
                        :created_at => Time.now,
                        :publish_results => false,
                        :preview_enabled => false)
    test.elements.each('TASK') {|task| Importer.import_question(quiz,task)}
  end

  def self.import_question(quiz,task)
    content = "<div>#{task.elements['DESCRIPTION'].text}</div><div>#{task.elements['QUESTION'].text}</div>"
    choices = task.elements['SINGLE-CHOICE']
    if choices
      type = Question::SingleOptionType
    else
      choices = task.elements['MULTI-CHOICE']
      return unless choices
      type = Question::MultiOptionType
    end
    question = Question.create!(:content => content, 
                                :subject_group_id => quiz.subject.subject_group_id,
                                :question_type => type)

    quiz.quiz_items.create(:preview_only => false, :question_id => question.id)
    choices.elements.each('OPTION') {|option| Importer.import_answer(question,option)}
  end

  def self.import_answer(question,option)
    Answer.create!(:question_id => question.id, :content => option.text, :is_correct => (option.attributes['CORRECT'] == 'true'))
  end
end

require File.dirname(__FILE__) + '/../../test_helper'
require 'services/importer'

class ImporterTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_import_empty_testset
    content = ''
    content += '<TESTSET>'
    content += '</TESTSET>'
    subject = init_data(content)
    assert_equal(0,subject.quizzes.length)
  end

  def test_import_empty_quiz
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    quiz = assert_single_quiz(subject)
    assert_equal(0,quiz.quiz_items.length)
  end

  def test_import_multiple_quizzes
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '  </TEST>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="2" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    assert_equal(2,subject.quizzes.length)
    assert_equal('test-1',subject.quizzes[0].name)
    assert_equal('Imported from test-1',subject.quizzes[0].description)
    assert_common_quiz_attributes(subject,subject.quizzes[0])
    assert_equal('test-2',subject.quizzes[1].name)
    assert_equal('Imported from test-2',subject.quizzes[1].description)
    assert_common_quiz_attributes(subject,subject.quizzes[1])
  end

  def test_import_test_with_single_choice_question
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '    <TASK>'
    content += '    <DESCRIPTION>Life, Universe and Everything?</DESCRIPTION>'
    content += '    <QUESTION>Whats the answer?</QUESTION>'
    content += '    <SINGLE-CHOICE>'
    content += '      <OPTION CORRECT="true">42</OPTION>'
    content += '      <OPTION>Chocolate</OPTION>'
    content += '      <OPTION>Purple</OPTION>'
    content += '    </SINGLE-CHOICE>'
    content += '    </TASK>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    question = assert_single_quiz_with_single_question(subject)
    assert_equal(Question::SingleOptionType,question.question_type)
    assert_equal(3,question.answers.length)
    assert_answer('42',true,question.answers[0])
    assert_answer('Chocolate',false,question.answers[1])
    assert_answer('Purple',false,question.answers[2])
  end

  def test_import_test_with_multi_choice_question
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '    <TASK>'
    content += '    <DESCRIPTION>Life, Universe and Everything?</DESCRIPTION>'
    content += '    <QUESTION>Whats the answer?</QUESTION>'
    content += '    <MULTI-CHOICE>'
    content += '      <OPTION CORRECT="true">42</OPTION>'
    content += '      <OPTION CORRECT="true">Chocolate</OPTION>'
    content += '      <OPTION>Purple</OPTION>'
    content += '    </MULTI-CHOICE>'
    content += '    </TASK>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    question = assert_single_quiz_with_single_question(subject)
    assert_equal(Question::MultiOptionType,question.question_type)
    assert_equal(3,question.answers.length)
    assert_answer('42',true,question.answers[0])
    assert_answer('Chocolate',true,question.answers[1])
    assert_answer('Purple',false,question.answers[2])
  end

  def test_import_test_with_word_question
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '    <TASK>'
    content += '    <DESCRIPTION>Life, Universe and Everything?</DESCRIPTION>'
    content += '    <QUESTION>Whats the answer?</QUESTION>'
    content += '    <WORD CORRECT="42"></WORD>'
    content += '    </TASK>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    question = assert_single_quiz_with_single_question(subject)
    assert_equal(Question::TextType,question.question_type)
    assert_equal(1,question.answers.length)
    assert_answer('^42$',true,question.answers[0])
  end

  def test_import_test_with_number_question
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '    <TASK>'
    content += '    <DESCRIPTION>Life, Universe and Everything?</DESCRIPTION>'
    content += '    <QUESTION>Whats the answer?</QUESTION>'
    content += '    <NUMBER CORRECT="42"></NUMBER>'
    content += '    </TASK>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    question = assert_single_quiz_with_single_question(subject)
    assert_equal(Question::NumberType,question.question_type)
    assert_equal(1,question.answers.length)
    assert_answer('42',true,question.answers[0])
  end

  def test_import_test_with_escaped_text
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '    <TASK>'
    content += '    <DESCRIPTION>&lt;pre&gt;Life, Universe and Everything?&lt;/pre&gt;</DESCRIPTION>'
    content += '    <QUESTION>Whats the answer?</QUESTION>'
    content += '    <SINGLE-CHOICE>'
    content += '      <OPTION CORRECT="true">42</OPTION>'
    content += '      <OPTION>&lt;Chocolate&gt;</OPTION>'
    content += '      <OPTION>Purple</OPTION>'
    content += '    </SINGLE-CHOICE>'
    content += '    </TASK>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    quiz = assert_single_quiz(subject)
    assert_equal(1,quiz.quiz_items.length)
    question = quiz.quiz_items[0].question
    assert_equal(subject.subject_group_id,question.subject_group_id)
    assert_equal(true,question.randomise?)
    assert_equal(TextFormatter::PlainFormat,question.text_format)
    assert_equal('<div><pre>Life, Universe and Everything?</pre></div><div>Whats the answer?</div>',question.content)
    assert_equal(TextFormatter::PlainFormat,question.text_format)
    assert_equal(Question::SingleOptionType,question.question_type)
    assert_equal(3,question.answers.length)
    assert_answer('42',true,question.answers[0])
    assert_answer('<Chocolate>',false,question.answers[1])
    assert_answer('Purple',false,question.answers[2])
  end

  def test_import_test_with_empty_description
    content = ''
    content += '<TESTSET>'
    content += '  <TEST>'
    content += '    <TEST-DESCRIPTION SUBJECT="test" NAME="1" TESTSIZE="0"></TEST-DESCRIPTION>'
    content += '    <TASK>'
    content += '    <DESCRIPTION></DESCRIPTION>'
    content += '    <QUESTION>Whats the answer?</QUESTION>'
    content += '    <SINGLE-CHOICE>'
    content += '      <OPTION CORRECT="true">42</OPTION>'
    content += '      <OPTION>Chocolate</OPTION>'
    content += '      <OPTION>Purple</OPTION>'
    content += '    </SINGLE-CHOICE>'
    content += '    </TASK>'
    content += '  </TEST>'
    content += '</TESTSET>'
    subject = init_data(content)
    quiz = assert_single_quiz(subject)
    assert_equal(1,quiz.quiz_items.length)
    question = quiz.quiz_items[0].question
    assert_equal(subject.subject_group_id,question.subject_group_id)
    assert_equal(true,question.randomise?)
    assert_equal(TextFormatter::PlainFormat,question.text_format)
    assert_equal('<div></div><div>Whats the answer?</div>',question.content)
    assert_equal(TextFormatter::PlainFormat,question.text_format)
    assert_equal(Question::SingleOptionType,question.question_type)
    assert_equal(3,question.answers.length)
    assert_answer('42',true,question.answers[0])
    assert_answer('Chocolate',false,question.answers[1])
    assert_answer('Purple',false,question.answers[2])
  end

  def assert_answer(content,is_correct,answer)
    assert_equal(content,answer.content)
    assert_equal(is_correct,answer.is_correct?)
  end

  def assert_single_quiz_with_single_question(subject)
    quiz = assert_single_quiz(subject)
    assert_equal(1,quiz.quiz_items.length)
    question = quiz.quiz_items[0].question
    assert_common_question_attributes(subject,question)
    assert_equal(TextFormatter::PlainFormat,question.text_format)
    question
  end

  def assert_common_question_attributes(subject,question)
    assert_equal(subject.subject_group_id,question.subject_group_id)
    assert_equal(true,question.randomise?)
    assert_equal(TextFormatter::PlainFormat,question.text_format)
    assert_equal('<div>Life, Universe and Everything?</div><div>Whats the answer?</div>',question.content)
  end

  def assert_single_quiz(subject)
    assert_equal(1,subject.quizzes.length)
    assert_equal('test-1',subject.quizzes[0].name)
    assert_equal('Imported from test-1',subject.quizzes[0].description)
    assert_common_quiz_attributes(subject,subject.quizzes[0])
    subject.quizzes[0]
  end

  def assert_common_quiz_attributes(subject,quiz)
    assert_equal(10,subject.quizzes[0].duration)
    assert_equal(true,subject.quizzes[0].randomise?)
    assert_equal(subject.id,subject.quizzes[0].subject_id)
    assert_equal(false,subject.quizzes[0].publish_results?)
    assert_equal(false,subject.quizzes[0].preview_enabled?)
  end

  TestSubject = 'TESTSBJ'
  TestFilename = "#{RAILS_ROOT}/temp/importer_test.xml"

  def init_data(content)
    f = File.new(TestFilename, File::CREAT|File::TRUNC|File::RDWR)
    f.write(content)
    f.close
    subject = Subject.create!(:name => TestSubject, :subject_group_id => subject_groups(:sg_1).id)
    begin 
      Importer.import_file(TestSubject,TestFilename)
    ensure
      File.delete(TestFilename)
    end
    subject
  end
end

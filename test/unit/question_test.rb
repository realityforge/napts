require File.dirname(__FILE__) + '/../test_helper'

class QuestionTest < Test::Unit::TestCase
  fixtures OrderedTables

  def test_has_resource
    assert_equal(true, questions(:q1).has_resource?)
    assert_equal(false, questions(:q2).has_resource?)
  end

  def test_number_answer_on_non_number_answer_question
    assert_equal(Question::MultiOptionType, questions(:q1).question_type)
    assert_equal('', questions(:q1).number_answer)
  end

  def test_text_answer_on_non_text_answer_question
    assert_equal(Question::MultiOptionType, questions(:q1).question_type)
    assert_equal('', questions(:q1).text_answer)
  end

  def test_choices_on_non_choices_question
    assert_equal(Question::NumberType, questions(:q11).question_type)
    assert_equal({}, questions(:q11).choices)
  end

  def test_number_answer_on_number_answer_question
    assert_equal(Question::NumberType, questions(:q11).question_type)
    assert_equal(answers(:q11_a).content, questions(:q11).number_answer)
  end

  def test_text_answer_on_text_text_question
    assert_equal(Question::TextType, questions(:q10).question_type)
    assert_equal(answers(:q10_a).content, questions(:q10).text_answer)
  end

  def test_choices_on_choices_question
    assert_equal(Question::MultiOptionType, questions(:q9).question_type)
    assert_equal(4, questions(:q9).choices.length)
    check_choice(questions(:q9),answers(:q9_a1))
    check_choice(questions(:q9),answers(:q9_a2))
    check_choice(questions(:q9),answers(:q9_a3))
    check_choice(questions(:q9),answers(:q9_a4))
  end

  def check_choice(q,a)
    assert_equal({:is_correct => a.is_correct, :content => a.content, :position => a.position}, q.choices[a.id.to_s])
  end

  def test_create_number_question
    question = Question.new(:content => 'x',
                            :question_type => Question::NumberType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat,
                            :number_answer => '42')
    assert_valid( question )

    question.save!
    question.reload

    assert_equal('x', question.content)
    assert_equal(Question::NumberType, question.question_type)
    assert_equal(subject_groups(:sg_1).id, question.subject_group_id)
    assert_not_nil(question.corrected_at)
    assert_equal(TextFormatter::PlainFormat, question.text_format)
    assert_equal(1, question.answers.length)
    assert_equal('42', question.answers[0].content)
    assert_equal(true, question.answers[0].is_correct?)
    assert_equal(1, question.answers[0].position)
  end

  def test_invalid_create_number_question
    question = Question.new(:content => 'x',
                            :question_type => Question::NumberType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat,
                            :number_answer => 'X')
    assert_equal(false, question.valid?)
    assert_equal('Must specify a number answer.', question.errors[:base])
  end

  def test_create_text_question
    question = Question.new(:content => 'What am i?',
                            :question_type => Question::TextType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat,
                            :text_answer => '^ACE$')
    assert_valid( question )

    question.save!
    question.reload

    assert_equal('What am i?', question.content)
    assert_equal(Question::TextType, question.question_type)
    assert_equal(subject_groups(:sg_1).id, question.subject_group_id)
    assert_not_nil(question.corrected_at)
    assert_equal(TextFormatter::PlainFormat, question.text_format)
    assert_equal(1, question.answers.length)
    assert_equal('^ACE$', question.answers[0].content)
    assert_equal(true, question.answers[0].is_correct?)
    assert_equal(1, question.answers[0].position)
  end

  def test_invalid_create_text_question
    question = Question.new(:content => 'x',
                            :question_type => Question::TextType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat,
                            :text_answer => '')
    assert_equal(false, question.valid?)
    assert_equal('Must have a answer of length of 1 or more.', question.errors[:base])
  end

  def test_create_single_choice_question
    question = Question.new(:content => 'Should I have 1 or 2 scotch and cokes?',
                            :question_type => Question::SingleOptionType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat)
    question.choices = {
      '1' => {:content => '1', :is_correct => false, :position => 1},
      '2' => {:content => '2', :is_correct => true, :position => 2}
    }
    assert_valid( question )

    question.save!
    question.reload

    assert_equal('Should I have 1 or 2 scotch and cokes?', question.content)
    assert_equal(Question::SingleOptionType, question.question_type)
    assert_equal(subject_groups(:sg_1).id, question.subject_group_id)
    assert_not_nil(question.corrected_at)
    assert_equal(TextFormatter::PlainFormat, question.text_format)
    assert_equal(2, question.answers.length)
    assert_equal('1', question.answers[0].content)
    assert_equal(false, question.answers[0].is_correct?)
    assert_equal(1, question.answers[0].position)
    assert_equal('2', question.answers[1].content)
    assert_equal(true, question.answers[1].is_correct?)
    assert_equal(2, question.answers[1].position)
  end


  def test_create_single_choice_question
    question = Question.new(:content => 'Should I have 1 or 2 scotch and cokes?',
                            :question_type => Question::MultiOptionType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat)
    question.choices = {
      '1' => {:content => '1', :is_correct => true, :position => 1},
      '2' => {:content => '2', :is_correct => true, :position => 2}
    }
    assert_valid( question )

    question.save!
    question.reload

    assert_equal('Should I have 1 or 2 scotch and cokes?', question.content)
    assert_equal(Question::MultiOptionType, question.question_type)
    assert_equal(subject_groups(:sg_1).id, question.subject_group_id)
    assert_not_nil(question.corrected_at)
    assert_equal(TextFormatter::PlainFormat, question.text_format)
    assert_equal(2, question.answers.length)
    assert_equal('1', question.answers[0].content)
    assert_equal(true, question.answers[0].is_correct?)
    assert_equal(1, question.answers[0].position)
    assert_equal('2', question.answers[1].content)
    assert_equal(true, question.answers[1].is_correct?)
    assert_equal(2, question.answers[1].position)
  end

  def test_invalid_create_choice_question_with_no_correct_answer
    question = Question.new(:content => 'Should I have 1 or 2 scotch and cokes?',
                            :question_type => Question::SingleOptionType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat)
    question.choices = {
      '1' => {:content => '1', :is_correct => false, :position => 1},
      '2' => {:content => '2', :is_correct => false, :position => 2}
    }
    assert_equal(false, question.valid?)
    assert_equal('Must select single correct answer.', question.errors[:base])
  end

  def test_invalid_create_choice_question_with_empty_content
    question = Question.new(:content => 'Should I have 1 or 2 scotch and cokes?',
                            :question_type => Question::SingleOptionType,
                            :subject_group_id => subject_groups(:sg_1).id,
                            :corrected_at => Time.now,
                            :text_format => TextFormatter::PlainFormat)
    question.choices = {
      '1' => {:content => '1', :is_correct => false, :position => 1},
      '2' => {:content => '', :is_correct => true, :position => 2}
    }
    assert_equal(false, question.valid?)
    assert_equal('All answers must have content of length 1 or more.', question.errors[:base])
  end

  def test_get_answers_on_non_randomized
    4.times do |i|
      ## Make sure non-randomised always returned in correct order
      answer_ids1 = questions(:q4).get_answers.collect{|a| a.id}
      answer_ids2 = questions(:q4).get_answers.collect{|a| a.id}
      assert_equal(answer_ids1,answer_ids2)
    end
  end

  def test_get_answers_on_randomized
    count = 0
    10.times do |i|
      ## Make sure non-randomised always returned in correct order
      answer_ids1 = questions(:q1).get_answers.collect{|a| a.id}
      answer_ids2 = questions(:q1).get_answers.collect{|a| a.id}
      count += 1 if (answer_ids1 == answer_ids2)
    end
    flunk('Answers not randomized') if (count == 10)
  end
end

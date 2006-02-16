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
end

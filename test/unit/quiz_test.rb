require File.dirname(__FILE__) + '/../test_helper'

class QuizTest < Test::Unit::TestCase
  fixtures OrderedTables
  
  def test_address_enabled?
    quiz = Quiz.find( quizzes(:quiz_1).id )
    assert_equal( true, quiz.address_enabled?( '0.0.0.0' ) )
    assert_equal( false, quiz.address_enabled?( '127.0.0.12' ) )
  end  
end

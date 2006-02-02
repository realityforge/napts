require File.dirname(__FILE__) + '/../../test_helper'
require 'students/quiz_attempt_controller'

#Re-raise errors caught by the controller.
class Students::QuizAttemptController; def rescue_action(e) raise e end; end

require 'quiz_attempt'

class QuizAttempt < ActiveRecord::Base
  cattr_accessor :time_up

  alias :old_time_up :time_up?

  def time_up?(time); @@time_up ? true : old_time_up(time); end
end

class Students::QuizAttemptControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Students::QuizAttemptController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {},
        {:user_id => users(:sleepy_user).id, :role => :student} )
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quizzes))
    assert_equal(1,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_1).id,assigns(:quizzes)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_from_invalid_computer
    get(:show_question, {:id => quizzes(:quiz_3).id}, {:user_id => users(:peter_user).id, :role => :student})
    assert_redirected_to(:action => 'list')
    assert_equal('Quiz not active for this Computer.',flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_when_user_already_completed_quiz
    get(:show_question, {:id => quizzes(:quiz_2).id}, {:user_id => users(:peter_user).id, :role => :student})
    assert_redirected_to(:action => 'list')
    assert_equal('User already completed Quiz.',flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_when_time_is_up
    QuizAttempt.time_up = true
    get(:show_question, {:id => quizzes(:quiz_1).id}, {:user_id => users(:peter_user).id, :role => :student})
    QuizAttempt.time_up = false
    assert_not_nil(assigns(:quiz_attempt))
    assert_equal(true,assigns(:quiz_attempt).completed?)
    assert_redirected_to(:controller => 'students/results', :action => 'show', :id => assigns(:quiz_attempt).id)
    assert_equal('Sorry, your time is up.',flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_when_last_question
    quiz_attempt = quizzes(:quiz_1).quiz_attempt_for_user(users(:peter_user).id)
    quiz_attempt.next_response.update_attribute(:completed, true)
    quiz_attempt.next_response.update_attribute(:completed, true)
    assert_equal(true,quiz_attempt.next_response.nil?)
    get(:show_question, {:id => quizzes(:quiz_1).id}, {:user_id => users(:peter_user).id, :role => :student})
    assert_not_nil(assigns(:quiz_attempt))
    assert_equal(true,assigns(:quiz_attempt).completed?)
    assert_redirected_to(:controller => 'students/results', :action => 'show', :id => assigns(:quiz_attempt).id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_get
    get(:show_question, {:id => quizzes(:quiz_1).id}, {:user_id => users(:peter_user).id, :role => :student})
    assert_response(:success)
    assert_template('show_question')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_attempt))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_post_with_answers
    post(:show_question,
        {:id => quizzes(:quiz_1).id, :answers => [answers(:q1_a1).id]},
        {:user_id => users(:peter_user).id, :role => :student})
    assert_redirected_to(:action => 'show_question', :id => quizzes(:quiz_1).id)
    assert_not_nil(assigns(:quiz_attempt))
    assert_not_nil(assigns(:quiz_response))
    assert_equal(1,assigns(:quiz_response).answers.length)
    assert_equal(answers(:q1_a1).id, assigns(:quiz_response).answers[0].id)
    assert_equal(true, assigns(:quiz_response).completed?)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_show_question_post_with_zero_answers
    post(:show_question,
        {:id => quizzes(:quiz_1).id},
        {:user_id => users(:peter_user).id, :role => :student})
    assert_redirected_to(:action => 'show_question', :id => quizzes(:quiz_1).id)
    assert_not_nil(assigns(:quiz_attempt))
    assert_not_nil(assigns(:quiz_response))
    assert_equal(0,assigns(:quiz_response).answers.length)
    assert_equal(true, assigns(:quiz_response).completed?)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end
end

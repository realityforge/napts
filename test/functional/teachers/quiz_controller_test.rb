require File.dirname(__FILE__) + '/../../test_helper'
require 'teachers/quiz_controller'

#Re-raise errors caught by the controller.
class Teachers::QuizController; def rescue_action(e) raise e end; end

module UploadedFile
  attr_accessor :original_filename, :content_type
end


class Teachers::QuizControllerTest < Test::Unit::TestCase
  fixtures OrderedTables

  def setup
    @controller = Teachers::QuizController.new
    @request = ActionController::TestRequest.new
    @response = ActionController::TestResponse.new
  end

  def test_list
    get(:list,
        {},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_pages))
    assert_not_nil(assigns(:quizzes))
    assert_equal(1,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_3).id,assigns(:quizzes)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_with_query
    get(:list,
        {:q => 'an'},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('list')
    assert_valid_markup
    assert_not_nil(assigns(:quiz_pages))
    assert_not_nil(assigns(:quizzes))
    assert_equal(1,assigns(:quizzes).length)
    assert_equal(quizzes(:quiz_3).id,assigns(:quizzes)[0].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_get
    get(:new,
        {},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_post_with_error
    post(:new,
        {:quiz => {
             :name => '', :duration => 10, :randomise => true, 
             :subject_id => subjects(:subject_2).id, :description => 'Y', :prelim_enable => true
           }},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('new')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_not_nil(assigns(:quiz).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_new_post
    post(:new,
        {:quiz => {
             :name => 'X', :duration => 10, :randomise => true, 
             :subject_id => subjects(:subject_2).id, :description => 'Y', :prelim_enable => true
           }},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_not_nil(assigns(:quiz))
    assert_redirected_to(:action => 'show', :id => assigns(:quiz).id)
    assert_nil(flash[:alert])
    assert_equal('Quiz was successfully created.',flash[:notice])
    assigns(:quiz).reload
    assert_equal('X',assigns(:quiz).name)
    assert_equal(10,assigns(:quiz).duration)
    assert_equal(true,assigns(:quiz).randomise)
    assert_equal(true,assigns(:quiz).prelim_enable)
    assert_equal(subjects(:subject_1).id,assigns(:quiz).subject_id)
    assert_equal('Y',assigns(:quiz).description)
  end

  def test_edit_get
    get(:edit,
        {:id => quizzes(:quiz_2).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_post_with_errors
    post(:edit,
        {:id => quizzes(:quiz_2).id, :quiz => {
             :name => '', :duration => 10, :randomise => true, 
             :subject_id => subjects(:subject_2).id, :description => 'Y', :prelim_enable => true
           }},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('edit')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_not_nil(assigns(:quiz).errors[:name])
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_edit_post
    post(:edit,
        {:id => quizzes(:quiz_2).id, :quiz => {
             :name => 'X', :duration => 10, :randomise => true, 
             :subject_id => subjects(:subject_2).id, :description => 'Y', :prelim_enable => true
           }},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_not_nil(assigns(:quiz))
    assert_redirected_to(:action => 'show', :id => assigns(:quiz).id)
    assert_nil(flash[:alert])
    assert_equal('Quiz was successfully updated.',flash[:notice])
    assigns(:quiz).reload
    assert_equal('Y',assigns(:quiz).description)
  end

  def test_toggle_preview_status_off
    assert_equal(true, quizzes(:quiz_2).prelim_enable?)
    post(:toggle_preview_status,
         {:id => quizzes(:quiz_2).id, :preview_status => 'false', :q => 'q', :page => '1'}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :q => 'q', :page => '1')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quizzes(:quiz_2).reload
    assert_equal(false, quizzes(:quiz_2).prelim_enable?)
  end

  def test_toggle_preview_status_on
    assert_equal(false, quizzes(:quiz_3).prelim_enable?)
    post(:toggle_preview_status,
         {:id => quizzes(:quiz_3).id, :preview_status => 'true', :q => 'q', :page => '1'}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_2).id})
    assert_redirected_to(:action => 'list', :q => 'q', :page => '1')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quizzes(:quiz_3).reload
    assert_equal(true, quizzes(:quiz_3).prelim_enable?)
  end

  def test_show
    get(:show,
        {:id => quizzes(:quiz_2).id},
        {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_response(:success)
    assert_template('show')
    assert_valid_markup
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_questions
    get(:list_questions,
        {:id => quizzes(:quiz_4).id},
        {:user_id => users(:admin_user).id, :role => :teacher, :subject_id => subjects(:subject_3).id})
    assert_response(:success)
    assert_template('list_questions')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_not_nil(assigns(:question_pages))
    assert_not_nil(assigns(:questions))
    assert_equal(3,assigns(:questions).length)
    assert_equal(questions(:q7).id,assigns(:questions)[0].id)
    assert_equal(questions(:q8).id,assigns(:questions)[1].id)
    assert_equal(questions(:q9).id,assigns(:questions)[2].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_list_questions_with_query
    get(:list_questions,
        {:id => quizzes(:quiz_4).id, :q => 'e'},
        {:user_id => users(:admin_user).id, :role => :teacher, :subject_id => subjects(:subject_3).id})
    assert_response(:success)
    assert_template('list_questions')
    assert_valid_markup
    assert_not_nil(assigns(:quiz))
    assert_not_nil(assigns(:question_pages))
    assert_not_nil(assigns(:questions))
    assert_equal(3,assigns(:questions).length)
    assert_equal(questions(:q7).id,assigns(:questions)[0].id)
    assert_equal(questions(:q8).id,assigns(:questions)[1].id)
    assert_equal(questions(:q9).id,assigns(:questions)[2].id)
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
  end

  def test_add_item 
    assert_nil(quizzes(:quiz_4).quiz_items.find(:first, :conditions => ['id = ?', questions(:q7).id]))
    post(:add_item, 
         {:id => quizzes(:quiz_4).id, :question_id => questions(:q7).id, :q => 'q', :page => '1'},
        {:user_id => users(:admin_user).id, :role => :teacher, :subject_id => subjects(:subject_3).id})
    assert_redirected_to(:action => 'list_questions', :id => quizzes(:quiz_4).id, :q => 'q', :page => '1')
    assert_nil(flash[:alert])
    assert_nil(flash[:notice])
    quizzes(:quiz_4).reload
    assert_not_nil(quizzes(:quiz_4).quiz_items.find(:first, :conditions => ['question_id = ?', questions(:q7).id]))
  end

  def test_destroy 
    post(:destroy, 
         {:id => quizzes(:quiz_1).id, :q => 'q', :page => '1'}, 
         {:user_id => users(:lecturer_user).id, :role => :teacher, :subject_id => subjects(:subject_1).id})
    assert_redirected_to(:action => 'list', :q => 'q', :page => '1')
    assert_nil(flash[:alert])
    assert_equal('Quiz was successfully deleted.',flash[:notice])
    assert_equal(false, Quiz.exists?(quizzes(:quiz_1).id))
  end
end

class Students::SubjectController < Students::BaseController
  verify :method => :get, :only => %w( list )

  def list
    conditions = params[:q] ? ['name LIKE ?', "%#{params[:q]}%"] : '1 = 1'
    @subject_pages, @subjects = paginate( :subjects,
                                          :conditions => conditions,
                                          :order_by => 'name',
                                          :per_page => 10 )
  end
end

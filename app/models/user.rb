class User < ActiveRecord::Base
  has_many( :quiz_attempts, :order => 'created_at DESC', :dependent => true )
  has_and_belongs_to_many( :demonstrates_for, 
                           :class_name => 'Subject', 
			   :order => 'name', 
			   :join_table => 'demonstrators', 
			   :uniq => true )
  has_and_belongs_to_many( :teaches, 
                           :class_name => 'Subject', 
			   :order => 'name', 
			   :join_table => 'teachers', 
			   :uniq => true )
  has_and_belongs_to_many( :enrolled_in, 
                           :class_name => 'Subject', 
			   :order => 'name', 
			   :join_table => 'students', 
			   :uniq => true )
  attr_accessible( :name )
  validates_uniqueness_of( :name )
  validates_presence_of( :name )
  
  def self.authenticate(name, password)
    if do_authenticate?(name,password)
      user = User.find_by_name(name)
      user = User.create!('name' => name, 'administrator' => false) if user.nil?
      user
    else 
      nil
    end
  end
    
  def demonstrator?
    self.demonstrates_for.size > 0
  end
  
  def demonstrator_for?( subject_id )
    begin
      self.demonstrates_for.find(subject_id)
      return true
    rescue
      return false
    end
  end
  
  def teacher?
    self.teaches.size > 0
  end
  
  def teaches?( subject_id )
    begin
      self.teaches.find(subject_id)
      return true
    rescue
      return false
    end
  end

private 
  
  def self.do_authenticate?(name,password)
    if Module.constants.include?("ApplicationConfig") && ApplicationConfig.respond_to?(:auth_config) && ApplicationConfig.auth_config['exe']
      output = ''
      IO.popen(ApplicationConfig.auth_config['exe'],"w+") do |auth|
        auth.puts "#{name}:#{password}"
        auth.close_write
        output = auth.read
      end
      output == "VALID\n"
    else
      name == password
    end
  end  
end

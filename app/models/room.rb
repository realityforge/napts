class Room < ActiveRecord::Base
  validates_length_of( :name, :within => 1..50 )
  validates_uniqueness_of( :name )
  has_many( :computers, :exclusively_dependent => true, :order => 'ip_address' )
  has_and_belongs_to_many( :quizzes )

  def addresses
    @addresses = self.computers.collect {|c| c.ip_address}.join("\n") unless @addresses
    @addresses
  end

  def addresses=(value)
    @addresses = value
  end

  def validate
   if @addresses
     addys = gen_address_list
     invalid = []
     addys.each do |address|
        invalid << address unless (address =~ Computer::AddressRegex)
      end
     if invalid.length > 0
       self.errors.add_to_base("The following ip addresses are badly formatted: #{invalid.join(' ')}")
     end
   end
  end

  def after_save
    if @addresses
      self.computers.clear
      gen_address_list.each {|address| self.computers.create!(:ip_address => address)}
    end
  end

  private

  def gen_address_list
    @addresses.gsub(/\s+/,' ').split(/\s/).uniq
  end
end

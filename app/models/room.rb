class Room < ActiveRecord::Base
  validates_length_of( :name, :within => 1..50 )
  validates_uniqueness_of( :name )
  has_many( :computers, :dependent => true )
  has_and_belongs_to_many( :quizzes )

  def addresses
    self.computers.collect {|c| c.ip_address}.join("\n")
  end

  def addresses=(value)
    addys = value.chomp.split(/\s/).uniq
    invalid = []
    addys.each do |address|
      invalid << address unless (address =~ Computer::AddressRegex)
    end
    if invalid.length > 0
      self.errors.add_to_base("The following ip addresses are badly formatted: #{invalid.join(' ')}")
    else
      self.computers.clear
      addys.each {|address| self.computers.create!(:ip_address => address)}
    end
  end
end

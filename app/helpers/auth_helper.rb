module AuthHelper
  if ! const_defined?(:Roles)
    RoleDescriptions = ["Administrator", "Educator", "Demonstrator", "Student"]
    Roles = [:administrator, :educator, :demonstrator, :student]
  end

  def to_role(requested_role)
    RoleDescriptions.detect {|r| r == requested_role } ? requested_role.downcase.to_sym : nil
  end

  def get_verified_role(user, requested_role)
    role = to_role(requested_role)

    case role
    when :administrator then return role if user.administrator?
    when :educator then return role if user.educator?
    when :demonstrator then return role if user.demonstrator?
    when :student then return role
    end
    return nil
  end

  def verify_admin
    raise Napts::SecurityError unless current_user.administrator?
  end
end

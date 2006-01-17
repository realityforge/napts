module AuthHelper
  if ! const_defined?(:Roles)
    RoleDescriptions = ["Administrator", "Educator", "Demonstrator", "Student"]
    Roles = [:administrator, :educator, :demonstrator, :student]
  end

  def to_role(requested_role)
    RoleDescriptions.detect {|r| r == requested_role } ? requested_role.downcase.to_sym : nil
  end

  def get_verified_role(user, requested_role, subject_id)
    role = to_role(requested_role)

    case role
    when :administrator then return role if user.administrator?
    when :educator then return role if user.educator? && user.educator_for?(subject_id)
    when :demonstrator then return role if user.demonstrator? && user.demonstrator_for?(subject_id)
    when :student then return role
    end
    return nil
  end

  def requires_subject?(role)
    role == :demonstrator || role == :educator
  end

  def verify_admin
    raise Napts::SecurityError unless current_user.administrator?
  end

  def verify_demonstrator
    raise Napts::SecurityError unless current_user.demonstrator?
    subject_id = current_subject_id
    if subject_id
      raise Napts::SecurityError unless 
        current_user.demonstrates_for.find(:first, ['id = ?', subject_id])
    end
  end

  def verify_teacher
    raise Napts::SecurityError unless current_user.educator?
    subject_id = current_subject_id
    if subject_id
      raise Napts::SecurityError unless 
        current_user.educates_for.find(:first, ['id = ?', subject_id])
    end
  end

end

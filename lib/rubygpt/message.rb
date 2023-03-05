class Rubygpt::Message
  attr_reader :role, :content

  def initialize(role: "user", content: "")
    @role = role
    @content = content
  end

  def to_h
    {
      role: role,
      content: content,
    }
  end

  def user_role?
    role == "user"
  end

  def assistant_role?
    role == "assistant"
  end
end

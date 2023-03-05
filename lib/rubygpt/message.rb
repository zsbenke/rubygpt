class Rubygpt::Message
  attr_reader :role, :content

  def initialize(role: 'user', content: '')
    @role = role
    @content = content
  end
end

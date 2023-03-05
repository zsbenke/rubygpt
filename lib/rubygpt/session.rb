class Rubygpt::Session
  attr_reader :path, :format, :messages

  def initialize(path, format: :repl)
    @path = path
    @format = format
    @messages = []
  end

  def repl?
    format == :repl
  end

  def block?
    format == :block
  end

  private

  def add_message(role:, content:)
    content.strip!
    content.chomp!

    message = Rubygpt::Message.new(role: role, content: content)
    @messages.append(message)
  end
end

class Rubygpt::Session
  attr_reader :path, :format, :messages

  def initialize(path, format: :repl)
    @path = path
    @format = format

    reset_messages
  end

  def self.new_by_format(path, format)
    case format
    when :repl
      Rubygpt::Session::Repl.new(path)
    when :block
      Rubygpt::Session::Block.new(path)
    else
      raise "Unknown format: #{format}"
    end
  end

  def repl?
    format == :repl
  end

  def block?
    format == :block
  end

  def add_message(role:, content:)
    content.strip!
    content.chomp!

    message = Rubygpt::Message.new(role: role, content: content)
    @messages.append(message)
  end

  def reset_messages
    @messages = []
  end

  def user_prompt
    "ask> "
  end

  def assistant_prompt
    "=> Response"
  end
end

class Rubygpt::Session
  attr_reader :path, :format, :messages

  def initialize(path, format: :repl)
    @path = path
    @format = format
    @messages = []
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

  private

  def add_message(role:, content:)
    content.strip!
    content.chomp!

    message = Rubygpt::Message.new(role: role, content: content)
    @messages.append(message)
  end
end

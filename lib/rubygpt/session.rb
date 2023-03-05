class Rubygpt::Session
  attr_reader :path, :format

  def initialize(path, format: :repl)
    @path = path
    @format = format
  end

  def repl?
    format == :repl
  end

  def block?
    format == :block
  end
end

require 'optparse'

require_relative "rubygpt/version"
require_relative "rubygpt/message"
require_relative "rubygpt/chat"
require_relative "rubygpt/session"
require_relative "rubygpt/session/repl"
require_relative "rubygpt/session/block"

module Rubygpt
  class Error < StandardError; end

  def self.run
    options = {}

    OptionParser.new do |opts|
      opts.banner = "Usage: rubygpt [options]"

      opts.on("-s", "--session-path PATH", "Path to a session file") do |path|
        options[:session_path] = File.expand_path(path.chomp)
      end

      opts.on("-f", "--format FORMAT", "Format of the context file") do |format|
        options[:format] = format.chomp
      end

      opts.on("-p", "--process PATH", "Path to a file to process") do |path|
        options[:process_path] = File.expand_path(path.chomp)
      end
    end.parse!

    session_path = options[:session_path] if options[:session_path]
    process_path = options[:process_path] if options[:process_path]
    format = options[:format] ? options[:format] : :repl

    if process_path
      chat = Rubygpt::Chat.new(ENV['OPENAI_API_KEY'], session_path: process_path, format: format, output: false)
      chat.process
    else
      chat = Rubygpt::Chat.new(ENV['OPENAI_API_KEY'], session_path: session_path, format: format)

      while buffer = Readline.readline(chat.session.user_prompt.colorize(:red), true)
        chat.process_input(buffer)
      end
    end
  end
end

require "openai"
require "colorize"
require "readline"
require "securerandom"
require "date"
require "tty-markdown"
require "optparse"
require "clipboard"
require "awesome_print"

module Rubygpt
  class Chat
    attr_reader :session

    def initialize(api_key = ENV["OPENAI_API_KEY"], session_path: nil, format: :repl, output: true)
      @client = OpenAI::Client.new(access_token: api_key)
      @format = format
      @output = output

      prepare_session(session_path)
      greet
    end

    def process_input(input)
      case input
      when ""
        handle_empty
      when "help"
        help
      when "exit"
        exit
      when "new"
        new
      when "save"
        save
      when "copy"
        copy
      when "reload"
        reload
      when "history"
        history
      when "clear"
        clear
      when "debug"
        debug
      when "edit"
        edit
      else
        session.add_message(role: "user", content: input)
        query_assistant(input)
      end
    end

    def process
      last_message = session.messages.last

      if last_message.user_role?
        input = last_message.content.gsub(session.user_prompt, "").strip.chomp
        query_assistant(input)
        save
      end
    end

    def convert
      convert_to_format = @format == :repl ? :block : :repl
      new_session = Rubygpt::Session.new_by_format(session.path, convert_to_format)

      session.messages.each do |message|
        new_session.add_message(role: message.role, content: message.content)
      end
      @session = new_session

      save
    end

    def create
      session.reset_messages
      session.add_message(role: "user", content: "")
      save
    end

    private

    def query_assistant(input)
      print_message "Thinking...", color: :yellow

      messages = session.messages.map(&:to_h)
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: messages
        })
      output = response.dig("choices", 0, "message", "content").strip
      output_markdown = TTY::Markdown.parse(output)

      print_message session.assistant_prompt, color: :green, bold: true
      print_message output_markdown

      session.add_message(role: "assistant", content: output)
    end

    def prepare_session(path)
      default_path = File.expand_path(ENV["RUBYGPT_SESSION_PATH"] || ".")

      path = if path
               path
             else
               current_time = DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")
               File.join(default_path, "#{current_time} Chat.md")
             end

      @session = Rubygpt::Session.new_by_format(path, @format)
      @session.load
    end

    def greet
      print_message 'Welcome! Type "help" to see available commands'
    end

    def handle_empty
      if session.messages.empty?
        print_message "Ask something or type 'help' for more information.", color: :green
      elsif session.messages.last.user_role?
        query_assistant(session.messages.last.content)
      else
        print_message "Type 'history' to see the chat history.", color: :green
      end
    end

    def help
      message = <<~HELP
        Commands:
          help - show this help
          exit - exit the chat
          new - start a new session
          save - save the session to a file
          copy - copy the path to the session file to the clipboard
          reload - reload the session from the current session file
          history - show the session history
          clear - clear the screen
          debug - show debug information
          edit - open the $EDITOR to edit the current message before sending
      HELP

      print_message message
    end

    def edit
      filename = SecureRandom.hex
      filepath = "/tmp/#{filename}.md"

      system "#{ENV['EDITOR']} #{filepath}"
      input = File.read(filepath)
      File.delete(filepath)

      input_markdown = TTY::Markdown.parse(input)
      print_message input_markdown

      session.add_message(role: "user", content: input)
      query_assistant(input)
    end

    def copy
      Clipboard.copy(session.path)

      print_message "Copied path to the clipboard.", color: :green
    end

    def reload
      session.reset_messages
      session.load

      print_message "Reloaded session", color: :green
    end

    def save
      File.write(session.path, session.render)

      print_message "Saved chat to #{session.path}", color: :green
    end

    def new
      prepare_session(nil)
      clear if output?

      print_message "New session started", color: :green
    end

    def clear
      system("clear")
    end

    def history
      return print_message("No history", color: :green) if session.messages.empty?

      lines = session.messages.map do |message|
        markdown = TTY::Markdown.parse(message.content).strip.chomp

        if message.user_role?
          "#{session.user_prompt.colorize(:red)}#{markdown}"
        else
          session.assistant_prompt.colorize(:green) + "\n" + markdown
        end
      end.join("\n\n")

      print_message(lines)
    end

    def debug
      ap session.messages, indent: 2
    end

    def print_message(message, color: nil, bold: false)
      message = message.colorize(:green) if color
      message = message.bold if bold

      puts message if output?
    end

    def output?
      @output == true
    end
  end
end

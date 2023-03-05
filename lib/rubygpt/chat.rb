require 'openai'
require 'colorize'
require 'readline'
require 'securerandom'
require 'date'
require 'tty-markdown'
require 'optparse'
require 'clipboard'
require 'awesome_print'

module Rubygpt
  class Chat
    attr_reader :session

    def initialize(api_key = ENV['OPENAI_API_KEY'], session_path: nil, format: :repl, output: true)
      @client = OpenAI::Client.new(access_token: api_key)
      @format = format
      @output = output

      prepare_session(session_path)
      greet
    end

    def process_input(input)
      return if input.empty?

      case input
      when 'exit'
        exit
      when 'new'
        new
      when 'save'
        save
      when 'copy'
        copy
      when 'history'
        history
      when 'clear'
        clear
      when 'debug'
        debug
      when 'edit'
        edit
      else
        session.add_message(role: 'user', content: input)
        query_assistant(input)
      end
    end

    def process
      last_message = session.messages.last

      if last_message.role == 'user'
        input = last_message.content.gsub(session.user_prompt, '').strip.chomp
        query_assistant(input)
        save
      end
    end

    private

    def query_assistant(input)
      print_message 'Thinking...', color: :yellow

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

      session.add_message(role: 'assistant', content: output)
    end

    def prepare_session(path)
      path = if path
                        path
                      else
                        current_time = DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")
                        File.join(Dir.home, 'Documents', 'Chats', "Chat-#{current_time}.md")
                      end

      @session = Rubygpt::Session.new_by_format(path, @format)
      @session.load
    end

    def greet
      print_message 'Welcome! Type "exit" to quit at any time.', color: :green
    end

    def edit
      filename = SecureRandom.hex
      filepath = "/tmp/#{filename}.md"

      system "#{ENV['EDITOR']} #{filepath}"
      input = File.read(filepath)
      File.delete(filepath)

      input_markdown = TTY::Markdown.parse(input)
      print_message input_markdown

      session.add_message(role: 'user', content: input)
      query_assistant(input)
    end

    def copy
      Clipboard.copy(session.path)

      print_message "Copied path to the clipboard.", color: :green
    end

    def save
      File.write(session.path, session.render)

      print_message "Saved chat to #{session.path}", color: :green
    end

    def new
      prepare_session(nil)
      clear if output?

      print_message 'New session started', color: :green
    end

    def clear
      system('clear')
    end

    def history
      return print_message("No history", color: :green) if session.messages.empty?

      lines = session.messages.map do |message|
        markdown = TTY::Markdown.parse(message.content).strip.chomp

        if message.role == 'user'
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

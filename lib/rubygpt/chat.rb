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
    attr_reader :messages

    def initialize(api_key = ENV['OPENAI_API_KEY'], context_path = nil, format = 'repl', output: true)
      @client = OpenAI::Client.new(access_token: api_key)
      @context_path = context_path
      @format = format

      print_message 'Welcome! Type "exit" to quit at any time.', color: :green

      prepare_context
    end

    def process_input(input)
      return if input.empty?
      return exit if input == 'exit'
      return save if input == 'save'
      return copy if input == 'copy'
      return new_session if input == 'new'
      return history if input == 'history'
      return clear if input == 'clear'
      return debug if input == 'debug'

      if input == 'edit'
        filename = SecureRandom.hex
        filepath = "/tmp/#{filename}.md"

        system "#{ENV['EDITOR']} #{filepath}"
        input = File.read(filepath)
        File.delete(filepath)

        input_markdown = TTY::Markdown.parse(input)
        puts input_markdown
      end

      add_message( role: 'user', content: input)

      query_assistant(input)
    end

    def query_assistant(input)
      print_message 'Thinking...', color: :yellow
      response = @client.chat(
        parameters: {
          model: "gpt-3.5-turbo",
          messages: @messages
        })
      output = response.dig("choices", 0, "message", "content").strip
      output_markdown = TTY::Markdown.parse(output)

      # print response
      print_message assistant_prompt, color: :green, bold: true
      print_message output_markdown

      add_message(role: 'assistant', content: output)
    end

    def save
      @context_path = if @context_path
                        @context_path
                      else
                        current_time = DateTime.now.strftime("%Y-%m-%d_%H-%M-%S")
                        File.join(Dir.home, 'Documents', 'Chats', "Chat-#{current_time}.md")
                      end

      File.write(@context_path, collect_messages)

      puts "Saved chat to #{@context_path}".colorize(:green)
    end

    def user_prompt
      "ask> "
    end

    def assistant_prompt
      "=> Response"
    end

    private

    Message = Struct.new(:role, :content)

    def output?
      @output
    end

    def print_message(message, color: nil, bold: false)
      message = message.colorize(:green) if color
      message = message.bold if bold

      puts message if output?
    end

    def copy
      return puts "No context file to copy".colorize(:green) unless @context_path

      Clipboard.copy(@context_path)
      puts "Copied path to the clipboard.".colorize(:green)
    end

    def new_session
      @messages = []
      @context_path = nil

      clear
      puts "Started new session".colorize(:green)
    end

    def clear
      system('clear')
    end

    def history
      return puts "No history".colorize(:green) if @messages.empty?

      lines = @messages.map do |message|
        markdown = TTY::Markdown.parse(message[:content]).strip.chomp

        if message[:role] == 'user'
          "#{user_prompt.colorize(:red)}#{markdown}"
        else
          assistant_prompt.colorize(:green) + "\n" + markdown
        end
      end.join("\n\n")

      puts lines
    end

    def debug
      ap @messages, indent: 2
    end

    def collect_messages
      send("collect_messages_as_#{@format}")
    end

    def collect_messages_as_repl
      @messages.map do |message|
        role = message[:role]
        content = message[:content]

        if role == 'user'
          "#{user_prompt}#{content.strip.chomp}"
        else
          "#{assistant_prompt}\n#{content.strip.chomp}"
        end
      end.join("\n\n")
    end

    def collect_messages_as_block
      text = ''
      assistant_block = false

      messages.each do |msg|
        if msg[:role] == 'assistant'
          unless assistant_block
            text += "\n<!-- block assistant -->\n"
            assistant_block = true
          end
          text += "#{msg[:content]}\n"
        else
          if assistant_block
            text += "<!-- endblock -->\n\n"
            assistant_block = false
          end
          text += "#{msg[:content]}\n"
        end
      end

      text.chomp!
      text += "\n<!-- endblock -->\n" if assistant_block

      text
    end

    def prepare_context
      @messages = []

      return unless @context_path

      send("prepare_context_from_#{@format}")
    end

    def prepare_context_from_repl
      current_message = { role: '', content: '' }

      File.readlines(@context_path).each do |line|
        if line.start_with?(user_prompt)
          current_message[:role] == 'assistant' ? add_message(**current_message) : nil

          current_message = { role: 'user', content: line.gsub(user_prompt, '') }
        elsif line.start_with?(assistant_prompt)
          current_message[:role] == 'user' ? add_message(**current_message) : nil

          current_message = { role: 'assistant', content: line.gsub(assistant_prompt, '') }
        else
          current_message[:content] += line
        end
      end

      @messages << current_message
    end

    def prepare_context_from_block
      role = 'user'
      content = ''

      File.readlines(@context_path).each do |line|
        if line.include?('<!-- block assistant -->')
          add_message(role: role, content: content)
          role = 'assistant'
          content = ''
        elsif line.include?('<!-- endblock -->')
          add_message(role: role, content: content)
          role = 'user'
          content = ''
        else
          content += line
        end
      end

      add_message(role: role, content: content)

      @messages.reject! { |msg| msg[:content].empty? }
    end

    def add_message(role:, content:)
      content.strip!
      content.chomp!

      message = Message.new(role, content)
      @messages.append(message)
    end
  end
end

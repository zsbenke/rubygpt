class Rubygpt::Session::Repl < Rubygpt::Session
  def load
    current_message = { role: '', content: '' }

    File.readlines(path).each do |line|
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

    add_message(**current_message)
  end

  def render
    @messages.map do |message|
      if message.role == 'user'
        "#{user_prompt}#{message.content.strip.chomp}"
      else
        "#{assistant_prompt}\n#{message.content.strip.chomp}"
      end
    end.join("\n\n")
  end

  private

  def user_prompt
    "ask> "
  end

  def assistant_prompt
    "=> Response"
  end
end
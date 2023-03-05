class Rubygpt::Session::Repl < Rubygpt::Session

  def load
    return reset_messages unless File.exist?(path)

    current_message = { role: "", content: "" }

    File.readlines(path).each do |line|
      if line.start_with?(user_prompt)
        current_message[:role] == "assistant" ? add_message(**current_message) : nil

        current_message = { role: "user", content: line.gsub(user_prompt, "") }
      elsif line.start_with?(assistant_prompt)
        current_message[:role] == "user" ? add_message(**current_message) : nil

        current_message = { role: "assistant", content: line.gsub(assistant_prompt, "") }
      else
        current_message[:content] += line
      end
    end

    add_message(**current_message)
  end

  def render
    @messages.map do |message|
      if message.user_role?
        "#{user_prompt}#{message.content.strip.chomp}"
      else
        "#{assistant_prompt}\n#{message.content.strip.chomp}"
      end
    end.join("\n\n")
  end
end

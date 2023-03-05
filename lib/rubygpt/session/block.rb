class Rubygpt::Session::Block < Rubygpt::Session
  def load
    return reset_messages unless File.exist?(path)

    role = "user"
    content = ""

    File.readlines(path).each do |line|
      if line.include?("<!-- block assistant -->")
        add_message(role: role, content: content)
        role = "assistant"
        content = ""
      elsif line.include?("<!-- endblock -->")
        add_message(role: role, content: content)
        role = "user"
        content = ""
      else
        content += line
      end
    end

    add_message(role: role, content: content)

    @messages.reject! { |message| message.content.empty? }
  end

  def render
    text = ""
    assistant_block = false

    messages.each do |message|
      if message.assistant_role?
        unless assistant_block
          text += "\n<!-- block assistant -->\n"
          assistant_block = true
        end
        text += "#{message.content}\n"
      else
        if assistant_block
          text += "<!-- endblock -->\n\n"
          assistant_block = false
        end
        text += "#{message.content}\n"
      end
    end

    text.chomp!
    text += "\n<!-- endblock -->\n" if assistant_block

    text
  end
end

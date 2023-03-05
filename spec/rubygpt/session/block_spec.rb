RSpec.describe Rubygpt::Session::Block do
  let(:path) { File.expand_path("spec/fixtures/files/chat_block.md") }

  subject(:session) { described_class.new(path) }

  before do
    session.load
  end

  describe "#load" do
    context "when the file exists" do
      it "loads the session from a file" do
        expect(session.messages[0].role).to eq "user"
        expect(session.messages[0].content).to eq "Hello!"
        expect(session.messages[1].role).to eq "assistant"
        expect(session.messages[1].content).to eq "Hello, how can I assist you today?"
      end
    end

    context "when the file does not exist" do
      let(:path) { "does_not_exist.md" }

      it "sets messages to empty" do
        expect(session.messages).to be_empty
      end
    end
  end

  describe "#render" do
    subject(:render) { session.render }

    before do
      session.messages << Rubygpt::Message.new(role: "user", content: "Thank you!")
    end

    it "renders the session as text" do
      expect(render).to eq \
        "Hello!\n\n" \
        "<!-- block assistant -->\n" \
        "Hello, how can I assist you today?\n" \
        "<!-- endblock -->\n\n" \
        "Thank you!"
    end
  end
end

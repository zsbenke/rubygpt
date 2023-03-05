RSpec.describe Rubygpt::Message do
  subject(:message) { described_class.new role: role, content: content }

  describe "#initialize" do
    context "when role is not specified" do
      let(:role) { nil }
      let(:content) { "Hello" }

      subject(:message) { described_class.new content: content }

      it "sets the default role" do
        expect(message.role).to eq "user"
      end
    end

    context "when role is specified" do
      let(:role) { "assistant" }
      let(:content) { "Hello" }

      it "sets the role" do
        expect(message.role).to eq "assistant"
      end
    end

    context "when content is not specified" do
      let(:role) { "user" }

      subject(:message) { described_class.new role: role }

      it "sets the default content" do
        expect(message.content).to eq ""
      end
    end
  end
end

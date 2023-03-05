RSpec.describe Rubygpt::Chat do
  let(:api_key) { "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" }
  subject(:chat) { described_class.new api_key, output: false }

  describe "#process_input" do
    context "when input is empty" do
      let(:input) { "" }

      before { chat.process_input input }

      it "does nothing" do
        expect(chat.session.messages).to be_empty
      end
    end

    context "when input is exit" do
      let(:input) { "exit" }

      before do
        allow(chat).to receive(:exit)

        chat.process_input input
      end

      it "exits the chat" do
        expect(chat).to have_received(:exit)
      end
    end

    context "when input is new" do
      let(:input) { "new" }

      before { chat.process_input input }

      it "clears existing messages" do
        expect(chat.session.messages).to be_empty
      end
    end

    context "when input is save" do
      let(:input) { "save" }

      before do
        allow(chat).to receive(:save).and_return(true)

        chat.process_input input
      end

      it "saves the session" do
        expect(chat).to have_received(:save)
      end
    end

    context "when input is copy" do
      let(:input) { "copy" }

      before do
        allow(chat).to receive(:copy).and_return(true)

        chat.process_input input
      end

      it "copies the session to the clipboard" do
        expect(chat).to have_received(:copy)
      end
    end

    context "when i put is history" do
      let(:input) { "history" }

      before do
        allow(chat).to receive(:history).and_return(true)

        chat.process_input input
      end

      it "displays the history" do
        expect(chat).to have_received(:history)
      end
    end

    context "when input is clear" do
      let(:input) { "clear" }

      before do
        allow(chat).to receive(:clear).and_return(true)

        chat.process_input input
      end

      it "clears the screen" do
        expect(chat).to have_received(:clear)
      end
    end

    context "when input is debug" do
      let(:input) { "debug" }

      before do
        allow(chat).to receive(:debug).and_return(true)

        chat.process_input input
      end

      it "toggles debug mode" do
        expect(chat).to have_received(:debug)
      end
    end

    context "when input is not a command" do
      let(:input) { "hello" }

      before { VCR.use_cassette("hello") { chat.process_input input } }

      it "keeps messages" do
        expect(chat.session.messages[0].role).to eq "user"
        expect(chat.session.messages[0].content).to include "hello"
        expect(chat.session.messages[1].role).to eq "assistant"
        expect(chat.session.messages[1].content).to include("How can I assist you today?")
      end
    end
  end
end

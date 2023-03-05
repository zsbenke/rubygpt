RSpec.describe Rubygpt::Chat do
  let(:api_key) { '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' }
  subject(:chat) { described_class.new api_key, output: false }

  describe '#process_input' do
    before do
      VCR.use_cassette(cassette) do
        chat.process_input input
      end
    end

    context 'when input is hello' do
      let(:input) { 'hello' }
      let(:cassette) { 'hello' }

      it "keeps messages" do
        expect(chat.messages[0].role).to eq 'user'
        expect(chat.messages[0].content).to include 'hello'
        expect(chat.messages[1].role).to eq 'assistant'
        expect(chat.messages[1].content).to include('How can I assist you today?')
      end
    end

    context 'when input is new' do
      let(:input) { 'new' }
      let(:cassette) { 'new' }

      it "clears existing messages" do
        expect(chat.messages).to be_empty
      end
    end
  end
end

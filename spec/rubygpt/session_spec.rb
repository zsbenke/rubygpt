RSpec.describe Rubygpt::Session do
  let(:path) { File.expand_path('spec/fixtures/files/chat_repl.md') }

  subject(:session) { described_class.new(path) }

  describe '#initialize' do
    it "sets path" do
      expect(session.path).to eq path
    end

    context 'when format is not specified' do
      it "sets the default format" do
        expect(session.format).to eq :repl
      end
    end

    context 'when format is specified' do
      subject(:session) { described_class.new(path, format: :block) }

      it "sets the format" do
        expect(session.format).to eq :block
      end
    end
  end

  describe '#repl?' do
    context 'when format is repl' do
      it "returns true" do
        expect(session.repl?).to be true
      end
    end

    context 'when format is not repl' do
      subject(:session) { described_class.new(path, format: :block) }

      it "returns false" do
        expect(session.repl?).to be false
      end
    end
  end

  describe '#block?' do
    context 'when format is block' do
      subject(:session) { described_class.new(path, format: :block) }

      it "returns true" do
        expect(session.block?).to be true
      end
    end

    context 'when format is not block' do
      it "returns false" do
        expect(session.block?).to be false
      end
    end
  end
end

RSpec.describe ElifeParser::Text do
  subject { described_class.new(content) }

  let(:content) { "@manoel #quirino" }

  describe "content" do
    it "should get content" do
      expect(subject.content).to eql(content)
    end
  end

  describe "modified_text_without_special_caracters" do
    it "should remove @ and #" do
      expect(subject.modified_text_without_special_caracters).to eql(" manoel quirino ")
    end
  end
end

RSpec.describe ElifeParser::Text do
  subject { described_class.new(content) }

  let(:content) { "@manoel #quirino" }

  describe "content" do
    it "should get content" do
      expect(subject.content).to eql(content)
    end
  end

  describe "content_without_ats_and_fences" do
    it "should remove @ and #" do
      expect(subject.content_without_ats_and_fences).to eql("manoel quirino")
    end
  end
end

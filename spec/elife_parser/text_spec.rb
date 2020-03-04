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

  describe "modified_text" do
    it "should remove special caracters and change emojis" do
      expect(described_class.new("@livia.vilaca ##opa/&eba 🔥 🐷🐽.$ :?  .$ - -a º ρε👽😀☂❤华み원❤")
        .modified_text).to eql(" @livia.vilaca ##opa/&eba :fire: :pig: :pig_nose: a ρε :alien: :grinning: :heart: :heart: ")
    end
    it "should parse unicode heart and convert hearts" do
      expect(described_class.new("❤️ e 🔥 e ❤")
        .modified_text).to eql(" :heart: e :fire: e :heart: ")
    end
  end


end

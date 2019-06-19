RSpec.describe ElifeParser::Term do
  shared_examples "a matching term" do |text|
    it "matchs #{text}" do
      expect(subject.match?(ElifeParser::Text.new(text))).to be_truthy
    end
  end

  shared_examples "a not matching term" do |text|
    it "doesn't match #{text}" do
      expect(subject.match?(ElifeParser::Text.new(text))).to be_falsey
    end
  end

  # mover esse tree pra outro canto
  describe "tree" do
    it "should create tree" do
      skip
      p ElifeParser.tree(
        "(manoel OR (quirino neto \"k n\") OR silva OR (foo bar baz))  -teste -\"+foo  bar\""
      )
    end
  end


  describe "match" do
    context "rato OR roma" do
      subject {
        ElifeParser.tree("rato OR roma")
      }

      it_behaves_like "a matching term", " O rato roeu "
      it_behaves_like "a matching term", " a roupa de roma "
      it_behaves_like "a matching term", " rei de roma "
      it_behaves_like "a not matching term", " roeu a roupa "
    end
  end
end

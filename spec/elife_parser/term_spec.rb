RSpec.describe ElifeParser::Term do
  describe "tree" do
    it "should create tree" do
      p ElifeParser.tree(
        "manoel quirino neto -teste -\"foo bar\""
      )
    end
  end
end

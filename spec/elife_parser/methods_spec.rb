RSpec.describe ElifeParser::Methods do
  class Dummy
    extend ElifeParser::Methods
  end

  context "#tree" do
    it {
      expect(
        Dummy.tree(
          "one OR two OR three OR four five six"
        ).to_s
      ).to eql(
        "(one OR two OR three OR (four AND five AND six))"
      )
    }

    it {
      expect(
        Dummy.tree(
          "(test OR testando testado) -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "((test OR (testando AND testado)) AND NOT testei AND NOT \"nao pode se\")"
      )
    }

    it {
      expect(
        Dummy.tree(
          "(test testando OR testado) -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "(((test AND testando) OR testado) AND NOT testei AND NOT \"nao pode se\")"
      )
    }

    it {
      expect(
        Dummy.tree(
          "(test testando termo2 OR testado) -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "(((test AND testando AND termo2) OR testado) AND NOT testei AND NOT \"nao pode se\")"
      )
    }

    it {
      expect(
        Dummy.tree(
          "test testando termo -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "(test AND testando AND termo AND NOT testei AND NOT \"nao pode se\")"
      )
    }

    it {
      expect(
        Dummy.tree(
          "test testando OR termo -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "((test AND testando) OR (termo AND NOT testei AND NOT \"nao pode se\"))"
      )
    }

    it {
      expect(
        Dummy.tree(
          "test OR testando OR termo -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "(test OR testando OR (termo AND NOT testei AND NOT \"nao pode se\"))"
      )
    }

    it {
      expect(
        Dummy.tree(
          "test OR testando OR termo OR -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "(test OR testando OR termo OR (NOT testei AND NOT \"nao pode se\"))"
      )
    }

    it "should skip term with 2 tokens or less" do
      expect(
        Dummy.tree(
          "gosto de jogar bola"
        ).to_s
      ).to eql(
        "(gosto AND jogar AND bola)"
      )
    end

    it "quotes" do
      expect(
        Dummy.tree(
          "(\"coca cola\" bebida) OR (coca refrigerante)"
        ).to_s
      ).to eql(
        "((\"coca cola\" AND bebida) OR (coca AND refrigerante))"
      )
    end
  end

  context "#pre_processing" do
    it {
      expect(
        Dummy.pre_processing(
          "abrir abertura"
        )
      ).to eql(
        "abrir+abertura"
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "(abrir abertura) -foo -\"bar baz\""
        )
      ).to eql(
        "(abrir+abertura)+-foo+-\"bar+baz\""
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "abrir OR abertura"
        )
      ).to eql(
        "abrir|abertura"
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "abrir OR abertura OR abrindo conta) OR cadastro OR cadastrar OR renda OR documentos OR comprovante OR comprovantes"
        )
      ).to eql(
        "(abrir|abertura|abrindo+conta)|cadastro|cadastrar|renda|documentos|comprovante|comprovantes"
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "((abrir OR abertura OR abrindo conta) OR cadastro OR cadastrar OR renda OR documentos OR comprovante OR comprovantes"
        )
      ).to eql(
        "((abrir|abertura|abrindo+conta)|cadastro|cadastrar|renda|documentos|comprovante|comprovantes)"
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "(foo bar)(test ando)"
        )
      ).to eql(
        "(foo+bar)+(test+ando)"
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "“foo bar“"
        )
      ).to eql(
        "\"foo+bar\""
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "(test OR testando testado) -testei -\"nao pode se\""
        )
      ).to eql(
        "(test|testando+testado)+-testei+-\"nao+pode+se\""
      )
    }
  end
end

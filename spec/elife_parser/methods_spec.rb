RSpec.describe ElifeParser::Methods do
  class Dummy
    extend ElifeParser::Methods
  end

  context "#tree" do
    it {
      expect(
        Dummy.tree(
          "(test OR testando testado) -testei -\"nao pode se\""
        ).to_s
      ).to eql(
        "((test OR (testando AND testado)) AND NOT testei AND NOT \"nao pode se\")"
      )
    }
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
        "(abrir+abertura)+-foo+-\"bar baz\""
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
        "\"foo bar\""
      )
    }

    it {
      expect(
        Dummy.pre_processing(
          "(test OR testando testado) -testei -\"nao pode se\""
        )
      ).to eql(
        "(test|testando+testado)+-testei+-\"nao pode se\""
      )
    }
  end
end

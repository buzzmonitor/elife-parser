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
    context 'coca OR "Coca-Cola" OR Fanta OR Sprite OR "verde campo" OR yas OR ades OR charrua OR "agua Crystal" OR "del valle" OR "guarana jesus" OR "guarana tai" OR guarapan OR "matte leao" OR powerade OR schwepps OR "guarana simba" OR tuchaua' do
      subject {
        ElifeParser.tree('coca OR "Coca-Cola" OR Fanta OR Sprite OR "verde campo" OR yas OR ades OR charrua OR "agua Crystal" OR "del valle" OR "guarana jesus" OR "guarana tai" OR guarapan OR "matte leao" OR powerade OR schwepps OR "guarana simba" OR tuchaua')
      }

      it_behaves_like "a not matching term", "Es vergoinha de politicos só venha nos nas suas fazer o nessesario já mais só promessa safadeza deste politicos s.r comprando safadoes"
    end

    context '#jornalnacional OR "jornal nacional" OR #jn OR "no jn" OR "o jn" OR "ao jn" OR "do jn" OR "pro jn" OR "pelo jn" OR (bonner (majú OR jornal OR renata OR bancada OR globo OR apresentador))' do
      subject {
        ElifeParser.tree('#jornalnacional OR "jornal nacional" OR #jn OR "no jn" OR "o jn" OR "ao jn" OR "do jn" OR "pro jn" OR "pelo jn" OR (bonner (majú OR jornal OR renata OR bancada OR globo OR apresentador))')
      }

      it_behaves_like "a not matching term", 'Em audiência na Câmara, o jornalista disse que o ministro da Justiça está usando "tática cínica" - https://uol.page.link/fjeCs Glenn defende mensagens vazadas: "Moro tenta enganar o público" NOTICIAS.UOL.COM.BR'
    end
    
    context '(Coca OR coquinha OR "coca-cola" OR "coca cola") (cigarro OR fumar OR fuma OR envelhecimento OR nicotina OR envelhece OR envelhecer OR estudo OR pesquisa)' do
      subject {
        ElifeParser.tree('(Coca OR coquinha OR "coca-cola" OR "coca cola") (cigarro OR fumar OR fuma OR envelhecimento OR nicotina OR envelhece OR envelhecer OR estudo OR pesquisa)')
      }

      it_behaves_like "a not matching term", "Pessoas que bebem refrigerantes açucarados duas ou mais vezes por dia têm um risco 21% maior de morrer prematuramente  #ÉpocaNEGÓCIOS Grupo de Harvard analisou as dietas de mais de 100 mil pessoas por 34 anos e constatou que o consumo constante das bebidas açucaradas leva a mais mortes por doenças cardíacas e dois tipos de câncer"
    end
    
    context '"mais+"' do
      subject {
        ElifeParser.tree('"mais+"')
      }

      it_behaves_like "a not matching term", "mais"
      it_behaves_like "a not matching term", "quero mais 1"
      it_behaves_like "a matching term", "mais+"
      it_behaves_like "a matching term", "quero mais+ 1"
    end

    context "foo OR (jn (materia OR bar))" do
      subject {
        ElifeParser.tree("foo OR (jn (materia OR bar))")
      }

      it_behaves_like "a not matching term", "Aberta a temporada de férias da meninada: entra em cartaz, no dia 10, a 'Fábrica de Sonhos - Mostra de Animação', no Centro Cultural Banco do Brasil, na Praça da Liberdade. Veja programação completa na matéria!"
    end
    
    context "rato OR roma" do
      subject {
        ElifeParser.tree("rato OR roma")
      }

      it_behaves_like "a matching term", "O rato roeu"
      it_behaves_like "a matching term", "a roupa de roma"
      it_behaves_like "a matching term", "rei de roma"
      it_behaves_like "a matching term", "rato+eira"
      it_behaves_like "a not matching term", "roeu a roupa"
    end

    context "rat* OR roma" do
      subject {
        ElifeParser.tree("rat* OR roma")
      }

      it_behaves_like "a matching term", "A rata roeu"
      it_behaves_like "a matching term", "O rato roeu"
      it_behaves_like "a matching term", "a roupa de roma"
      it_behaves_like "a matching term", "rei de roma"
      it_behaves_like "a not matching term", "roeu a roupa"
    end

    context "futebol de (homem OR mulher)" do
      subject {
        ElifeParser.tree("futebol de (homem OR mulher)")
      }

      it_behaves_like "a matching term", "Futebol de Homem"
      it_behaves_like "a matching term", "Futebol de Mulher"
      it_behaves_like "a not matching term", "Futebol de Cegos"
    end

    context "gosto de *can*" do
      subject {
        ElifeParser.tree("gosto de *can*")
      }

      it_behaves_like "a matching term", "Gosto de cano"
      it_behaves_like "a matching term", "Gosto de encanamento"
      it_behaves_like "a not matching term", "Gosto de bolo"
    end

    context "url:(http://globo.com) AND gosto" do
      subject {
        ElifeParser.tree("url:(http://globo.com)")
      }

      it_behaves_like "a matching term", "http://globo.com"
      it_behaves_like "a not matching term", "globo"
    end

    context "(gosto de *can*) -\"non creio\"" do
      subject {
        ElifeParser.tree("(gosto de *can*) -\"non creio\"")
      }

      it_behaves_like "a matching term", "Gosto de cano"
      it_behaves_like "a matching term", "Gosto de encanamento"
      it_behaves_like "a not matching term", "Gosto de encanamento, non creio"
      it_behaves_like "a not matching term", "Gosto de bolo"
    end

    context "(Test OR 🙈 OR 🙊) -🙉" do
      subject {
        ElifeParser.tree("(Test OR 🙈 OR 🙊) -🙉")
      }

      it_behaves_like "a matching term", "Test Gosto de cano"
      it_behaves_like "a not matching term", "Gosto de encanamento"
      it_behaves_like "a matching term", "🙈"
      it_behaves_like "a matching term", "🙊"
      it_behaves_like "a not matching term", "🙊 🙉"
    end

    context "👨🏿" do
      subject {
        ElifeParser.tree("👨🏿")
      }

      it_behaves_like "a matching term", "👨🏿 🤦🏻‍♂"
      it_behaves_like "a matching term", "👨 🤦🏻‍♂"
    end

    context "🙈🙊" do
      subject {
        ElifeParser.tree("🙈🙊")
      }

      it_behaves_like "a matching term", "🙈 🙊"
      it_behaves_like "a matching term", "🙈🙊"
      it_behaves_like "a not matching term", "🙈"
    end

    context "❤" do
      subject {
        ElifeParser.tree("❤")
      }

      it_behaves_like "a matching term", "amo! ❤"
      it_behaves_like "a matching term", "anw ❤️"
      it_behaves_like "a not matching term", "🙈"
    end

    context '"gshow" OR #gshow OR #bomsucesso OR ("bom sucesso" (festa OR globo OR novela OR evento)) OR "caio blat" OR #caioblat' do
      subject {
        ElifeParser.tree('"gshow" OR #gshow OR #bomsucesso OR ("bom sucesso" (festa OR globo OR novela OR evento)) OR "caio blat" OR #caioblat')
      }

      it_behaves_like "a matching term", "bom sucesso festa"
      it_behaves_like "a matching term", "bom sucesso globo"
      it_behaves_like "a not matching term", "bom globo"
      it_behaves_like "a not matching term", "bom bomsucesso globo"
      it_behaves_like "a matching term", "bom #bomsucesso globo"
      it_behaves_like "a matching term", "bom globo gshow"
      it_behaves_like "a matching term", "globo #gshow"
      it_behaves_like "a matching term", "caio blat"
      it_behaves_like "a not matching term", "caio"
      it_behaves_like "a not matching term", "caioblat"
      it_behaves_like "a matching term", "#caioblat"
    end
  end
end

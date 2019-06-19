module ElifeParser
  module Methods

    def tree term
      if !term || !(term.is_a? String) || term.empty?
        return nil
      end

      tree_processed_term pre_processing(EmojiParser.tokenize(term))
    end

    def tree_processed_term term
      brackets = 0
      root = nil

      term = term.each_char.map do |c|
        case c
        when OPEN_BRACKET
          brackets += 1
        when CLOSE_BRACKET
          brackets -= 1
        end

        if c == '+' && brackets == 0 && !root
          root = Term.new
          root.expression = ElifeParser::Expression::AND
        elsif c == '|' && brackets == 0 && !root
          root = Term.new
          root.expression = ElifeParser::Expression::OR
        elsif c == '+' && brackets > 0
          c = '§'
        elsif c == '|' && brackets > 0
          c = '£'
        end
        c
      end.join

      if not root
        root = Term.new
        root.expression = ElifeParser::Expression::AND
      end

      terms = term.split(/\+|\|/)

      root.terms = Array.new
      terms.each do |t|
        node = Term.new
        if (t.include? '£') || (t.include? '§')
          t = t[t.index('(') + 1, t.rindex(')') - 1] #try
          t = t.gsub(/§/,"\+")
          t = t.gsub(/£/,"\|")
          node = tree_processed_term t
        else
          node.negative = t.start_with? '-'
          t = t.gsub(/[\"\+\-\(\)]/,"")
          node.value = t
        end
        root.terms.push node
      end

      root
    end

    def root_expression term
      brackets = 0
      term = term.each_char do |c|
        case c
        when OPEN_BRACKET
          brackets += 1
        when CLOSE_BRACKET
          brackets -= 1
        end

        if (c=='+'||c=='-')&&brackets==0 then
          return ElifeParser::Expression::AND
        elsif (c=='|')&&brackets==0 then
          return ElifeParser::Expression::OR
        end
      end
      ElifeParser::Expression::AND
    end

    def pre_processing term
      term = term.gsub(/\s\s+/, "\s")
      term = term.strip
      term = term.gsub(/ OR /,"|")
      term = term.downcase
      term = term.tr_s(
      "àáâãäåāăąçćĉċčðďđèéêëēĕėęěĝğġģĥħìíîïĩīĭįıĵķĸĺļľŀłñńņňŉŋòóôõöøōŏőŕŗřśŝşšſţťŧùúûüũūŭůűųŵýÿŷźżž",
      "aaaaaaaaacccccdddeeeeeeeeegggghhiiiiiiiiijkklllllnnnnnnooooooooorrrssssstttuuuuuuuuuuwyyyzzz")
      term = term.gsub(/\( /,"(")
      term = term.gsub(/ \)/,")")
      term = term.tr_s("\,","\+")
      term = term.tr_s(" ","\+")
      term = term.gsub(/\+\+/,"\, ")

      is_open = false

      term = term.each_char.map do |c|
        if c == '"'
          is_open = !is_open
        end

        c = c == '+' && is_open ? ' ' : c
      end.join
    end

  end
end

module ElifeParser
  module Methods

    def tree term
      if !term || !(term.is_a? String) || term.empty?
        return nil
      end

      skin_tone_re = /((?:\u{1f3fb}|\u{1f3fc}|\u{1f3fd}|\u{1f3fe}|\u{1f3ff}?))/

      tree_processed_term pre_processing(
        EmojiParser.tokenize(term).gsub(skin_tone_re, "")
      )
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

      term = verify_precedence(term)

      if not root
        root = Term.new
        root.expression = ElifeParser::Expression::AND
      end

      terms = term.split(/\+|\|/)

      root.terms = Array.new
      terms.each do |t|
        if t.size <= 2
          next
        elsif t.include?('¥')
          t = t.gsub("¥", "+")
          node = tree_processed_term t
        elsif (t.include? '£') || (t.include? '§')
          t = t[t.index('(') + 1, t.rindex(')') - 1] #try
          t = t.gsub(/§/,"\+")
          t = t.gsub(/£/,"\|")
          node = tree_processed_term t
        else
          node = Term.new
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
      chars = term.split('')
      open_bracket_count = chars.select {|c| c == '(' }.size
      close_bracket_count = chars.select {|c| c == ')' }.size
      diff = open_bracket_count - close_bracket_count

      if diff < 0
        term = "#{"(" * -diff}#{term}"
      elsif diff > 0
        term = "#{term}#{")" * diff}"
      end

      term = term.gsub(/\( /,"(")
      term = term.gsub(/ \)/,")")
      term = term.gsub('“', '"')
      term = term.gsub('”', '"')
      term = term.gsub(")(", ") (")
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

    def verify_precedence term
      term.include?('|') ? term.gsub("+", "¥") : term
    end

  end
end

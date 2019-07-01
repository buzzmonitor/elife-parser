module ElifeParser
  module Methods

    def tree term
      if !term || !(term.is_a? String) || term.empty?
        return nil
      end

      skin_tone_re = /((?:\u{1f3fb}|\u{1f3fc}|\u{1f3fd}|\u{1f3fe}|\u{1f3ff}?))/

      # .gsub('- :', '-:') -> remover espaço de emoji negativado

      tree_processed_term(pre_processing(
        EmojiParser.parse_unicode(term) {|emoji|
          # emoji tera espaço entre eles
          " :#{emoji.name}: "
        }
          .gsub(skin_tone_re, "")
          .gsub('- :', '-:')

      ))
    end

    def tree_processed_term term
      brackets = 0
      root = nil
      open_quotes = false

      term = term.each_char.map do |c|
        case c
        when OPEN_BRACKET
          brackets += 1
        when CLOSE_BRACKET
          brackets -= 1
        when QUOTE
          open_quotes = !open_quotes
        when '+'
          c = '§' if brackets > 0
          c = ' ' if open_quotes
        when '|'
          c = '£' if brackets > 0
        end
        c
      end.join

      root = get_root term

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
          t = t.strip
          node.value = t
        end
        root.terms.push node
      end

      root
    end

    def get_root term
      root = Term.new
      if term.include? "|"
        term.gsub!("+","¥")
        root.expression = ElifeParser::Expression::OR
      else
        root.expression = ElifeParser::Expression::AND
      end
      root
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
    end

  end
end

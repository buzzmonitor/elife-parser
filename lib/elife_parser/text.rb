module ElifeParser
  class Text
    attr_reader :content

    def initialize content
      @content = content
    end

    def sanitized_text
      @sanitized_text ||= begin
        " " + @content.downcase.tr_s(
          "àáâãäåāăąçćĉċčðďđèéêëēĕėęěĝğġģĥħìíîïĩīĭįıĵķĸĺļľŀłñńņňŉŋòóôõöøōŏőŕŗřśŝşšſţťŧùúûüũūŭůűųŵýÿŷźżž",
          "aaaaaaaaacccccdddeeeeeeeeegggghhiiiiiiiiijkklllllnnnnnnooooooooorrrssssstttuuuuuuuuuuwyyyzzz"
        ).gsub(/\s+/, " ") + " "
      end
    end


    def original_text
      @original_text ||= begin
        # remove white spaces
        sanitized_text.gsub(/\s\s+/, "\s")
      end
    end

    def modified_text
      @modified_text ||= begin
        skin_tone_re = /((?:\u{1f3fb}|\u{1f3fc}|\u{1f3fd}|\u{1f3fe}|\u{1f3ff}?))/
        final_text = sanitized_text
        final_text = final_text.gsub(/[^\.\w\s\@\#\&\u0370-\u03ff\u1f00-\u1fff\/\u{1f300}-\u{1f5ff}\u{1f600}-\u{1f64f}]/," ")
        final_text = EmojiParser.parse_unicode(final_text) { |emoji| " :#{emoji.name}: " }.gsub(skin_tone_re, "")
        final_text = final_text.gsub(/\.[\s+\$]/, " ")
        
        # remove white spaces
        final_text.gsub(/\s\s+/, "\s")
      end
    end

    def modified_text_without_special_caracters
      @modified_text_without_special_caracters ||= begin
        modified_text.gsub(/@|#/, "")
      end
    end
  end
end

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

      @sanitized_text
    end


    def original_text
      @original_text ||= begin
        # remove white spaces
        sanitized_text.gsub(/\s\s+/, "\s")
      end

      @original_text
    end

    def modified_text
      @modified_text ||= begin
        final_text = sanitized_text
        final_text = final_text.gsub("[^\\.\\w\\s\\@\\#\\&\\p{InGreek}\\uD800-\\uDBFF\\uDC00-\\uDFFF\\/]", " ")
        final_text = final_text.gsub("\\.[\\s+\\$]", " ")
        final_text = final_text.gsub("\\-", " ")
        final_text = EmojiParser.tokenize(final_text)
        # remove white spaces
        final_text.gsub(/\s\s+/, "\s")
      end

      @modified_text
    end

    def modified_text_without_special_caracters
      @modified_text_without_special_caracters ||= begin
        modified_text.gsub(/@|#/, "")
      end

      @modified_text_without_special_caracters
    end

  end
end

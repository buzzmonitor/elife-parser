# require "elife_parser/version"

module ElifeParser

  module Expression
    AND = "AND"
    OR = "OR"
  end

  class Term
    attr_accessor :expression
    attr_accessor :value
    attr_accessor :terms
    attr_accessor :negative

    def terminal?
      !@value.nil? && @terms.nil?
    end

    def match source
      #TODO clean source
      matchEval = false
      if terminal?
        matchEval = evaluate source
      else
        if @expression == Expression::AND
          matchEval = true
        end
        @terms.each do |term|
          if @expression == Expression::AND
            matchEval &= term.match source
          elsif @expression == Expression::OR
            matchEval |= term.match source
          end
        end
      end
    end

    private

    def evaluate source
      matchEval = false
      if @value && (@value.include "@" || @value.include? "#")
        matchEval = source.include? (" "+@value+" ")
      elsif @value
        source = source.gsub(/@|#/,"")
        matchEval = source.include? (" "+@value+" ")
      end
      if @negative
        matchEval = !matchEval
      end
      matchEval
    end
  end

  def tree term

    if !term || !(term.is_a? String) || term.empty?
      return nil
    end

    term = pre_processing term
    brackets = 0
    root=nil
    term = term.each_char.map do |c|
      brackets += c=='(' ? 1 : (c==')' ? -1 : 0)
      if (c=='+')&&brackets==0&&(not root)
        root = Term.new
        root.expression = ElifeParser::Expression.AND
      elsif (c=='|')&&brackets==0&&(not root)
        root = Term.new
        root.expression = ElifeParser::Expression.OR
      elsif c=='+'&&brackets>0
        c='§'
      elsif c=='|'&&brackets>0
        c='£'
      end
      c
    end.join

    if not root
      root = Term.new
      root.expression = ElifeParser::Expression.AND
    end

    terms = term.split(/\+|\|/)

    root.terms = Array.new
    terms.each do |t|
      node = Term.new
      if (t.include? '£') || (t.include? '§')
        t = t[t.index('(')+1,t.rindex(')')-1] #try
        t = t.gsub(/§/,"\+")
        t = t.gsub(/£/,"\|")
        node = tree t
      else
        node.negative = (t.start_with? '-') ? true : false
        t = t.gsub(/\"/,"")
        t = t.gsub(/[+-]/,"")
        t = t.gsub(/\(/,"")
        t = t.gsub(/\)/,"")
        node.value = t
      end
      root.terms.push node
    end
    root
  end

  private

  def root_expression term
    brackets = 0
    term = term.each_char do |c|
      brackets += c=='(' ? 1 : (c==')' ? -1 : 0)
      if (c=='+'||c=='-')&&brackets==0 then
        return ElifeParser::Expression.AND
      elsif (c=='|')&&brackets==0 then
        return ElifeParser::Expression.OR
      end
    end
    ElifeParser::Expression.AND
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

    open = false
    term = term.each_char.map do |c|
      if c == '"' then open = !open end
      c = c=='+'&&open ? ' ' : c
    end.join
  end


end

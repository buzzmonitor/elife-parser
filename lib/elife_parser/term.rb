module ElifeParser
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
      if @value && (@value.include?("@") || @value.include?("#"))
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
end

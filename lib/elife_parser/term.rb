module ElifeParser
  class Term
    attr_accessor :expression
    attr_accessor :value
    attr_accessor :terms
    attr_accessor :negative

    def terminal?
      !@value.nil? && @terms.nil?
    end

    def match? text
      #TODO clean source
      match_value = false

      if terminal?
        match_value = evaluate text
      else
        if @expression == Expression::AND
          match_value = true
        end
        @terms.each do |term|
          if @expression == Expression::AND
            match_value &= term.match? text
          elsif @expression == Expression::OR
            match_value |= term.match? text
          end
        end
      end

      match_value
    end

    def to_s
      if terminal?
        final_value = value

        if final_value.include? " "
          final_value = "\"#{final_value}\""
        end

        if negative
          final_value = "NOT #{final_value}"
        end

        final_value
      else
        children_to_s = @terms.map &:to_s

        joined = children_to_s.join(" #{@expression} ")

        if children_to_s.size > 1
          "(#{joined})"
        else
          joined
        end
      end
    end

    def inspect
      "<##{self.class.name} #{to_s}>"
    end

    private

    def evaluate text
      matchEval = false

      if @value && (@value.include?("@") || @value.include?("#"))
        matchEval = text.content.include? (" " + @value + " ")
      elsif @value
        matchEval = text.content_without_ats_and_fences.include? (" " + @value + " ")
      end

      if @negative
        matchEval = !matchEval
      end

      matchEval
    end
  end
end

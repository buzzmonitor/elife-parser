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

      if @value.start_with?("url:")
        matchEval = text.original_text.include?(" " + @value[4..-1] + " ");
      else
        end_with_star = @value.end_with?("*")
        start_with_star = @value.start_with?("*")

        if end_with_star && start_with_star
          # remove first and last star from term
          temp_value = @value[1..-2]
        elsif start_with_star
          temp_value = @value[1..-1] + " "
        elsif end_with_star
          temp_value = " " + @value[0..-2]
        else
          temp_value = " #{@value} "
        end

        if @value.include?("@") || @value.include?("#")
          matchEval = text.modified_text.include? temp_value
        elsif @value.include?("+")
          matchEval = text.modified_text_with_plus.include? temp_value
        else
          matchEval = text.modified_text_without_special_caracters.include? temp_value
        end
      end

      if @negative
        matchEval = !matchEval
      end

      matchEval
    end
  end
end

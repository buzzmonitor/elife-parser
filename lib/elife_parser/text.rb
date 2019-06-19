module ElifeParser
  class Text
    attr_reader :content

    def initialize content
      @content = content
    end

    def content_without_ats_and_fences
      @content_without_ats_and_fences ||= begin
        content.gsub(/@|#/,"")
      end

      @content_without_ats_and_fences
    end
  end
end

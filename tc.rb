require 'pry'

class TC 

  def initialize(template, clauses, sections)
    @template, @clauses, @sections = template, clauses, sections
  end


  def clauses_text(*clauses_ids)
    clauses_ids.inject([]) do |texts, clause_id| 
      texts << @clauses.find{|c| c[:id].to_s == clause_id.to_s}&.dig(:text)
    end
    .compact
    .join(";")
  end


  def generate
    @template.scan(/\[CLAUSE-\d*\]|\[SECTION-\d*\]/).each do |token|
      token_type, token_id = token[1..-2].split("-")
      clauses_ids = case token_type
        when "CLAUSE" 
          token_id
        when "SECTION"
          @sections.find{|s| s[:id].to_s == token_id.to_s}&.dig :clauses_ids
      end
      @template = @template.gsub token, clauses_text(*clauses_ids)
    end
    @template
  end

end


# example
template = "A T&C Document

This document is made of plaintext.
Is made of [CLAUSE-3].
Is made of [CLAUSE-4].
Is made of [SECTION-1].

Your legals."

clauses = [
  { "id": 1, "text": "The quick brown fox" },
  { "id": 2, "text": "jumps over the lazy dog" },
  { "id": 3, "text": "And dies" },
  { "id": 4, "text": "The white horse is white" }
]

sections = [
  { "id": 1, "clauses_ids": [1, 2] }
]

puts TC.new(template, clauses, sections).generate if $stdout.tty?
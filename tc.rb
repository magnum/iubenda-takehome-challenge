require 'pry'

class TC 

  # The regexp to math tokens inside the template
  TOKENS_REGEXP = /\[CLAUSE-\d*\]|\[SECTION-\d*\]/

  attr :sections_clauses_separator

  ##
  # Generates a Terms and Conditions text based on a text +template+ with tokens with the format +[CLAUSE-id]+ or  +[SECTION-id]+, 
  # and replacing them by passing a list +clauses+ and +sections+.
  #

  

  #@param template [String] the initial template for the terms and conditions's text
  #@param clauses [Array<Hash>] list of clasues
  #  * +id+ [Integer] the id of the clause
  #  * +text+ [String] the text of the clause
  #@param sections [Array<Hash>] list of sections
  #  * +id+ [Integer] the id of the clause
  #  * +clauses_ids+ [Array<Integer>] the list of clauses' ids
  def initialize(template=nil, clauses=nil, sections=nil, sections_clauses_separator=";")
    @sections_clauses_separator = sections_clauses_separator
    raise "Please provide template, clauses and sections" if [template,clauses,sections].compact.length < 3
    @template, @clauses, @sections = template, clauses, sections
  end


  # Get clauses' text, searching them by clause's id.
  # If multiple, they're joined by the separator string
  #
  # @param <Integer> *clauses_ids one or more clause_id(s) to get text from, passed as separated params
  # @return [String] the texts of the found clauses, joined by the separator string
  def clauses_text(*clauses_ids)
    clauses_ids.inject([]) do |texts, clause_id| 
      texts << @clauses.find{|c| c[:id].to_s == clause_id.to_s}&.dig(:text)
    end
    .compact
    .join(@sections_clauses_separator)
  end


  # Generates the terms and contitions text
  #
  # @return [String] terms and contitions by replacing clauses and sections
  def generate
    @template.scan(TOKENS_REGEXP).each do |token|
      token_type, token_id = token[1..-2].split("-")
      clauses_ids = case token_type
        when "CLAUSE" 
          token_id
        when "SECTION"
          @sections.find{|s| s[:id].to_s == token_id.to_s}&.dig :clauses_ids
      end
      @template = @template.gsub token, "#{clauses_text(*clauses_ids)}"
    end
    @template
  end

end


# example
template = "
  # I'm TC a template
  
  # CLAUSES: 
  [CLAUSE-1].
  [CLAUSE-2].

  # SECTIONS

  ## Section 1
  In section 1, [SECTION-1]

  Thank you for reading me.
"

clauses = [
  { "id": 1, "text": "I'm clause 1" },
  { "id": 2, "text": "I'm clause 2" },
  { "id": 3, "text": "i'm clause 3" },
  { "id": 4, "text": "i'm clause 4" }
]

sections = [
  { "id": 1, "clauses_ids": [3, 4] }
]

puts TC.new(template, clauses, sections, "; ").generate if $stdout.tty?
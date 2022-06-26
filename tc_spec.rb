require "minitest/autorun"
require "minitest/spec"
require_relative "tc"

describe TC do
  describe "#generate" do
    
    before do
      @template = "A T&C Document

      This document is made of plaintext.
      Is made of [CLAUSE-3].
      Is made of [CLAUSE-4].
      Is made of [SECTION-1].

      Your legals."

      @clauses = [
        { "id": 1, "text": "The quick brown fox" },
        { "id": 2, "text": "jumps over the lazy dog" },
        { "id": 3, "text": "And dies" },
        { "id": 4, "text": "The white horse is white" }
      ]

      @sections = [
        { "id": 1, "clauses_ids": [1, 2] }
      ]
    end


    it "raises error when not all params passed" do
      err = assert_raises RuntimeError do
        tc = TC.new
      end
      assert_match /Please provide template, clauses and sections/, err.message
    end


    it "returns a not empty tc" do
      tc = TC.new @template, @clauses, @sections
      refute_empty tc.generate
    end

    
    it "getting clause's text by id return the correct string" do
      tc = TC.new @template, @clauses, @sections
      @clauses.each do |clause|
        text = tc.clauses_text(clause[:id])
        assert_match /#{clause[:text]}/, text
      end 
    end

    
    it "getting sections's text by id return the correct clauses' strings with separator" do
      tc = TC.new @template, @clauses, @sections
      @sections.each do |section|
        section_text = tc.clauses_text(*section[:clauses_ids])
        expected_section_text = section[:clauses_ids].map{|id| tc.clauses_text(id)}.join(tc.sections_clauses_separator)
        assert_equal section_text, expected_section_text
      end 
    end


    it "tc includes clauses" do
      tc = TC.new @template, @clauses, @sections
      text = tc.generate
      @clauses.each do |clause|
        assert_match /#{clause[:text]}/, text
      end 
    end

    
    it "generated tc does not contain tokens anymore" do
      tc = TC.new @template, @clauses, @sections
      text = tc.generate
      refute_match TC::TOKENS_REGEXP, text
    end

    
    it "generated tc is correct" do
      tc = TC.new @template, @clauses, @sections
      text = tc.generate
      expected_text = "A T&C Document

      This document is made of plaintext.
      Is made of And dies.
      Is made of The white horse is white.
      Is made of The quick brown fox;jumps over the lazy dog.

      Your legals."
      assert_equal text, expected_text
    end
    
  end
end
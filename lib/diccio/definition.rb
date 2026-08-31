# frozen_string_literal: true

module Diccio
  class Definition
    attr_reader :word, :meaning, :date

    def initialize(word:, meaning:, date: nil)
      @word = word
      @meaning = meaning
      @date = date
    end
  end
end

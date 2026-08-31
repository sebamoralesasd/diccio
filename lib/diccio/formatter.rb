# frozen_string_literal: true

require_relative 'style'

module Diccio
  module Formatter
    EMPTY_MESSAGE = 'No hay definiciones.'

    def self.format(definitions)
      return EMPTY_MESSAGE if definitions.empty?

      definitions.group_by(&:word).map { |word, group| entry(word, group) }.join("\n\n")
    end

    def self.entry(word, definitions)
      meanings = definitions.map { |definition| "  #{definition.meaning}" }
      "#{Style.title("#{word.capitalize}:")}\n#{meanings.join("\n")}"
    end
  end
end

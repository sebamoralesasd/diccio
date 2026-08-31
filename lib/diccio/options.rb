# frozen_string_literal: true

module Diccio
  class Options
    attr_accessor :word, :date
    attr_writer :cache, :history

    def initialize
      @word = nil
      @date = nil
      @cache = true
      @history = false
    end

    def cache?
      @cache
    end

    def history?
      @history
    end
  end
end

# frozen_string_literal: true

require_relative 'api_client'
require_relative 'formatter'
require_relative 'logging'
require_relative 'repository'

module Diccio
  class App
    attr_reader :options, :repository, :api_client

    def initialize(options, repository: Repository.new, api_client: ApiClient.new)
      @options = options
      @repository = repository
      @api_client = api_client
    end

    def run
      puts Formatter.format(options.history? ? history : definitions)
    end

    private

    def history
      repository.history(options.date)
    end

    def definitions
      cached = options.cache? ? repository.find(options.word) : []
      return cached unless cached.empty?

      fetch(options.word)
    end

    def fetch(word)
      Logging.logger.info("\"#{word}\" no está en la base local")
      definitions = api_client.fetch_definitions(word)
      repository.replace(word, definitions)
      definitions
    end
  end
end

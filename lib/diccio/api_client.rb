# frozen_string_literal: true

require 'faraday'
require 'uri'
require_relative 'definition'
require_relative 'errors'
require_relative 'logging'

module Diccio
  class ApiClient
    DEFAULT_URL = 'https://rae-api.com/api/'
    TIMEOUT = 5
    LOG_OPTIONS = { headers: true, bodies: false, errors: true, log_level: :debug }.freeze

    attr_reader :connection

    def initialize(connection: build_connection)
      @connection = connection
    end

    def fetch_definitions(word)
      meanings = request(word).dig('data', 'meanings')
      Array(meanings).flat_map do |meaning|
        Array(meaning['senses']).filter_map do |sense|
          raw = sense['raw']
          Definition.new(word:, meaning: raw) if raw
        end
      end
    end

    private

    def request(word)
      Logging.logger.info("Consultando la API de la RAE: #{word}")
      response = connection.get("words/#{URI.encode_www_form_component(word)}")
      validate(response, word)

      response.body
    rescue Faraday::Error => e
      raise ApiError, "Fallo al consultar la API: #{e.message}"
    end

    def validate(response, word)
      raise NotFoundError, not_found_message(word) if response.status == 404
      raise ApiError, "Respuesta inesperada de la API: #{response.status}" unless response.success?
      raise ApiError, 'Respuesta inesperada de la API: el cuerpo no es JSON' unless response.body.is_a?(Hash)
      raise NotFoundError, not_found_message(word) unless response.body['ok']
    end

    def not_found_message(word)
      "No se encontró la palabra: #{word}"
    end

    def build_connection
      Faraday.new(url: ENV.fetch('DICCIO_API_URL', DEFAULT_URL)) do |conn|
        conn.options.timeout = TIMEOUT
        conn.options.open_timeout = TIMEOUT
        conn.response :json
        conn.response :logger, Logging.logger, **LOG_OPTIONS
      end
    end
  end
end

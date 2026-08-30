# frozen_string_literal: true

require 'faraday'
require 'json'
require 'uri'
require_relative 'clientdefaults'
require_relative 'connection'

module RaeApi
  class Error < StandardError
  end

  class Client
    include ClientDefaults

    def search(word)
      en_word = URI.encode_www_form_component(word)
      sub_path = "/words/#{en_word}"

      response = get(sub_path)
      raise Error, "HTTP #{response.status}: #{response.body}" unless response.status == 200
      raise Error, 'Respuesta inesperada de la API: el cuerpo no es JSON' unless response.body.is_a?(Hash)

      response.body
    rescue Faraday::Error => e
      raise Error, "Network error: #{e.message}"
    end

    private

    def get(path, params = nil)
      conn(path).get(params)
    end

    def conn(path)
      Connection.new(BASE_URL + path)
    end
  end
end

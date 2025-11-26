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
      raise Error if response.status != 200

      response.body
    end

    private

    def get(path, params = nil)
      conn(path).get(params)
    end

    def conn(path)
      @conn ||= Connection.new(BASE_URL + path)
    end
  end
end

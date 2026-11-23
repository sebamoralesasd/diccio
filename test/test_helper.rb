# frozen_string_literal: true

ENV['NO_COLOR'] = '1'
ENV['DICCIO_LOG_LEVEL'] = 'FATAL'

require 'minitest/autorun'
require_relative '../lib/diccio'

module Diccio
  module TestHelpers
    FIXTURES = File.expand_path('fixtures', __dir__)

    def fixture(name)
      File.read(File.join(FIXTURES, name))
    end

    def memory_repository
      Repository.new(database: Database.new(path: ':memory:'))
    end

    def stub_client(status:, body:, headers: { 'Content-Type' => 'application/json' })
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(/.*/) { [status, headers, body] }
      connection = Faraday.new do |conn|
        conn.response :json
        conn.adapter :test, stubs
      end
      ApiClient.new(connection:)
    end

    def definition(word, meaning, date = nil)
      Definition.new(word:, meaning:, date:)
    end
  end
end

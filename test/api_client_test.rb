# frozen_string_literal: true

require_relative 'test_helper'

module Diccio
  class ApiClientTest < Minitest::Test
    include TestHelpers

    def test_mapea_las_acepciones_a_definiciones
      client = stub_client(status: 200, body: fixture('vetusto.json'))
      definitions = client.fetch_definitions('vetusto')

      assert_equal 2, definitions.size
      assert_equal %w[vetusto vetusto], definitions.map(&:word)
      assert_equal '1. adj. Extremadamente viejo, anticuado.', definitions.first.meaning
    end

    def test_ignora_los_bloques_sin_acepciones
      client = stub_client(status: 200, body: fixture('vetusto.json'))

      # El fixture trae un meanings con senses vacío y otro sin la clave senses:
      # ninguno de los dos debe romper ni aportar definiciones.
      assert_equal 2, client.fetch_definitions('vetusto').size
    end

    def test_404_levanta_not_found_error
      client = stub_client(status: 404, body: '{"ok":false,"error":"NOT_FOUND"}')
      error = assert_raises(NotFoundError) { client.fetch_definitions('zzzznoexiste') }

      assert_equal 'No se encontró la palabra: zzzznoexiste', error.message
    end

    def test_ok_false_levanta_not_found_error
      client = stub_client(status: 200, body: '{"ok":false,"error":"NOT_FOUND"}')

      assert_raises(NotFoundError) { client.fetch_definitions('zzzznoexiste') }
    end

    def test_cuerpo_no_json_levanta_api_error
      client = stub_client(status: 200, body: '<html>502</html>', headers: { 'Content-Type' => 'text/html' })

      assert_raises(ApiError) { client.fetch_definitions('casa') }
    end

    def test_error_de_transporte_levanta_api_error
      stubs = Faraday::Adapter::Test::Stubs.new
      stubs.get(/.*/) { raise Faraday::ConnectionFailed, 'sin red' }
      connection = Faraday.new { |conn| conn.adapter :test, stubs }

      assert_raises(ApiError) { ApiClient.new(connection:).fetch_definitions('casa') }
    end
  end
end

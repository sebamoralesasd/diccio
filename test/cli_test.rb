# frozen_string_literal: true

require_relative 'test_helper'

module Diccio
  class CLITest < Minitest::Test
    def test_toma_la_palabra_posicional
      options = CLI.parse(['casa'])

      assert_equal 'casa', options.word
      refute_predicate options, :history?
      assert_predicate options, :cache?
    end

    def test_no_cache_desactiva_la_base_local
      refute_predicate CLI.parse(['--no-cache', 'casa']), :cache?
    end

    def test_history_sin_fecha
      options = CLI.parse(['--history'])

      assert_predicate options, :history?
      assert_nil options.date
    end

    def test_history_con_fecha
      assert_equal Date.new(2026, 8, 30), CLI.parse(['--history', '2026-08-30']).date
    end

    def test_fecha_invalida_levanta_usage_error
      error = assert_raises(UsageError) { CLI.parse(['--history', '30-08-2026']) }

      assert_match(/Fecha inválida/, error.message)
    end

    def test_fecha_inexistente_levanta_usage_error
      assert_raises(UsageError) { CLI.parse(['--history', '2026-02-31']) }
    end

    def test_sin_palabra_levanta_usage_error
      assert_raises(UsageError) { CLI.parse([]) }
    end

    def test_flag_desconocido_levanta_usage_error
      assert_raises(UsageError) { CLI.parse(['--noexiste']) }
    end
  end
end

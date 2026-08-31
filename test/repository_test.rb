# frozen_string_literal: true

require_relative 'test_helper'

module Diccio
  class RepositoryTest < Minitest::Test
    include TestHelpers

    def setup
      @repository = memory_repository
    end

    def test_guarda_y_recupera_en_orden_de_insercion
      @repository.save([definition('casa', 'primera'), definition('casa', 'segunda')])

      assert_equal %w[primera segunda], @repository.find('casa').map(&:meaning)
    end

    def test_find_devuelve_vacio_para_una_palabra_desconocida
      assert_empty @repository.find('zzzznoexiste')
    end

    def test_guardar_dos_veces_no_duplica
      2.times { @repository.save([definition('casa', 'primera')]) }

      assert_equal 1, @repository.find('casa').size
    end

    def test_replace_borra_las_acepciones_anteriores_de_la_palabra
      @repository.save([definition('casa', 'vieja'), definition('gato', 'intacta')])
      @repository.replace('casa', [definition('casa', 'nueva')])

      assert_equal ['nueva'], @repository.find('casa').map(&:meaning)
      assert_equal ['intacta'], @repository.find('gato').map(&:meaning)
    end

    def test_history_ordena_por_palabra
      @repository.save([definition('gato', 'g1'), definition('casa', 'c1'), definition('casa', 'c2')])

      assert_equal %w[casa casa gato], @repository.history.map(&:word)
      assert_equal %w[c1 c2 g1], @repository.history.map(&:meaning)
    end

    def test_history_filtra_por_fecha
      @repository.save([definition('casa', 'vieja', '2025-11-26')])
      @repository.save([definition('gato', 'nueva', '2026-08-30')])

      assert_equal ['gato'], @repository.history(Date.new(2026, 8, 30)).map(&:word)
      assert_empty @repository.history(Date.new(2020, 1, 1))
    end

    def test_la_fecha_por_defecto_es_la_de_hoy_en_hora_local
      @repository.save([definition('casa', 'sin fecha')])

      assert_equal Date.today.to_s, @repository.find('casa').first.date
    end
  end
end

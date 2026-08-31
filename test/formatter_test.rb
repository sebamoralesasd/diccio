# frozen_string_literal: true

require_relative 'test_helper'

module Diccio
  class FormatterTest < Minitest::Test
    include TestHelpers

    def test_agrupa_las_acepciones_bajo_la_palabra
      output = Formatter.format([definition('casa', '1. f. Edificio.'), definition('casa', '2. f. Familia.')])

      assert_equal "Casa:\n  1. f. Edificio.\n  2. f. Familia.", output
    end

    def test_separa_las_palabras_con_una_linea_en_blanco
      output = Formatter.format([definition('casa', 'c1'), definition('gato', 'g1')])

      assert_equal "Casa:\n  c1\n\nGato:\n  g1", output
    end

    def test_mensaje_para_la_lista_vacia
      assert_equal Formatter::EMPTY_MESSAGE, Formatter.format([])
    end
  end
end

# frozen_string_literal: true

require_relative 'test_helper'

module Diccio
  class DatabaseTest < Minitest::Test
    def test_path_inaccesible_levanta_database_error
      error = assert_raises(DatabaseError) { Database.new(path: '/no/existe/db.db') }

      assert_match(/Fallo al abrir la base de datos/, error.message)
    end
  end
end

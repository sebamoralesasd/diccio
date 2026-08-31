# frozen_string_literal: true

require 'date'
require_relative 'definition'

module Diccio
  class Repository
    SELECT = 'SELECT word, meaning, date FROM definitions'

    attr_reader :connection

    def initialize(database)
      @connection = database.connection
    end

    def find(word)
      rows = connection.execute("#{SELECT} WHERE word = ? ORDER BY id", word)
      rows.map { |row| to_definition(row) }
    end

    def history(date = nil)
      rows = if date.nil?
               connection.execute("#{SELECT} ORDER BY word, id")
             else
               connection.execute("#{SELECT} WHERE date = ? ORDER BY word, id", date.to_s)
             end
      rows.map { |row| to_definition(row) }
    end

    def save(definitions)
      connection.transaction { insert_all(definitions) }
    end

    def replace(word, definitions)
      connection.transaction do
        connection.execute('DELETE FROM definitions WHERE word = ?', word)
        insert_all(definitions)
      end
    end

    private

    def insert_all(definitions)
      definitions.each do |definition|
        connection.execute(<<~SQL, bind_params(definition))
          INSERT INTO definitions (word, meaning, date)
          VALUES (?, ?, ?)
          ON CONFLICT(word, meaning) DO NOTHING
        SQL
      end
    end

    def bind_params(definition)
      [definition.word, definition.meaning, definition.date || Date.today.to_s]
    end

    def to_definition(row)
      Definition.new(word: row['word'], meaning: row['meaning'], date: row['date'])
    end
  end
end

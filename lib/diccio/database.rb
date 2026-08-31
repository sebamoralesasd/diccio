# frozen_string_literal: true

require 'sqlite3'

module Diccio
  class Database
    DEFAULT_PATH = File.expand_path('../../db.db', __dir__)

    attr_reader :connection

    def initialize(path = ENV.fetch('DICCIO_DB', DEFAULT_PATH))
      @connection = SQLite3::Database.new(path)
      @connection.results_as_hash = true
      create_schema
    end

    def create_schema
      connection.execute_batch(<<~SQL)
        CREATE TABLE IF NOT EXISTS definitions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          word TEXT NOT NULL,
          meaning TEXT NOT NULL,
          date DATE DEFAULT (DATE('now', 'localtime')),
          created_at DATETIME DEFAULT CURRENT_TIMESTAMP
        );
        CREATE INDEX IF NOT EXISTS idx_word ON definitions (word);
        CREATE INDEX IF NOT EXISTS idx_date ON definitions (date);
        CREATE UNIQUE INDEX IF NOT EXISTS idx_word_meaning ON definitions (word, meaning);
      SQL
    end
  end
end

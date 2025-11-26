# frozen_string_literal: true

require 'sqlite3'

module RaeApi
  class Database
    def initialize
      path = "#{ENV.fetch('RAE_DB_PATH', '.')}/db.db"
      @db = SQLite3::Database.new(path)
      @db.execute <<~SQL
              CREATE TABLE IF NOT EXISTS definitions (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              word TEXT NOT NULL,
              meaning TEXT NOT NULL,
              date DATE DEFAULT (DATE('now')),
              created_at DATETIME DEFAULT CURRENT_TIMESTAMP
            );

        CREATE INDEX IF NOT EXISTS idx_word ON definitions(word);
        CREATE INDEX IF NOT EXISTS idx_date ON definitions(date);
      SQL
    end

    attr_reader :db

    def write(word, meaning)
      db.execute 'INSERT INTO definitions (word, meaning) VALUES (?, ?)', [word, meaning]
    end

    def search(word)
      mean = []
      db.execute('SELECT meaning FROM definitions WHERE word = ?', word).each do |row|
        mean << row.first
      end
      mean
    end

    def all(date)
      res = []

      query = 'SELECT meaning, word FROM definitions'
      result = if date.nil?
                 db.query(query)
               else
                 db.query("#{query} WHERE date = ?", [date])
               end
      result.each do |row|
        res << { meaning: row.first, word: row.last }
      end
      res
    end

    def group(date)
      res = []

      query = 'SELECT word, meaning FROM definitions'
      result = if date.nil?
                 db.query("#{query} ORDER BY word")
               else
                 db.query("#{query} WHERE date = ? ORDER BY word", [date])
               end

      current_word = nil
      current_meanings = []

      result.each do |row|
        word = row[0]
        meaning = row[1]

        if word != current_word
          res << { word: current_word, meaning: current_meanings } unless current_word.nil?
          current_word = word
          current_meanings = [meaning]
        else
          current_meanings << meaning
        end
      end

      res << { word: current_word, meaning: current_meanings } unless current_word.nil?
      res
    end
  end
end

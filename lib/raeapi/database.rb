require 'csv'

module RaeApi
  class Database
    def initialize
      path = "#{ENV.fetch('RAE_DB_PATH', '')}/db.csv"
      @db = CSV.open(path)
    rescue StandardError
      @db = CSV.open(path, 'w') do |csv|
        csv << %w[word meaning date]
      end
    end

    attr_reader :db

    def write(word, meaning, date)
      CSV.open(@db.path, 'a') do |csv|
        csv << [word, meaning, date]
      end
    end

    def search(word)
      mean = []
      CSV.foreach(@db.path, headers: true) do |fila|
        mean << fila['meaning'] if fila['word'] == word
      end
      mean
    end

    def all
      res = []
      CSV.foreach(@db.path, headers: true) do |fila|
        res << { meaning: fila['meaning'], word: fila['word'] }
      end
      res
    end
  end
end

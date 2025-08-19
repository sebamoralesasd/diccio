require_relative 'lib/raeapi/client'
require_relative 'lib/raeapi/database'

require 'date'

class RaeAPI
  def initialize
    @cli = RaeApi::Client.new
    @db = RaeApi::Database.new
  end

  def history
    res = @db.all
    puts 'No hay resultados.' if res.empty?

    res.each do |r|
      puts "#{r[:word]}: #{r[:meaning]}"
    end
    nil
  end

  def search(word)
    res = search_csv(word)
    return res unless res.empty?

    search_rae(word)
  end

  def search_csv(word)
    puts 'LOG: buscando en la base de datos local.'
    @db.search(word)
  end

  def search_rae(word)
    puts 'LOG: buscando en la base de datos de la RAE.'
    raw = @cli.search(word)
    ok = raw['ok']
    return raw['error'] unless ok

    data = raw['data']
    senses = []

    data['meanings'].each do |meanings|
      raw = senses(meanings)
      senses += ls_senses(raw)
    end
    return 'NO_DEF' if senses.empty?

    senses.each do |meaning|
      date = Date.today.to_s
      @db.write(word, meaning, date)
    end
    senses.join("\n")
  end

  private

  def ls_senses(senses)
    return '' if senses.nil? || senses.empty?

    senses.map do |s|
      s['raw']
    end
  end

  def senses(meanings)
    meanings['senses']
  end
end

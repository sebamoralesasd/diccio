# frozen_string_literal: true

require 'date'
require 'optparse'
require_relative 'app'
require_relative 'errors'
require_relative 'options'

module Diccio
  module CLI
    DATE_FORMAT = '%Y-%m-%d'
    DATE_PATTERN = /\A\d{4}-\d{2}-\d{2}\z/

    def self.run(argv)
      App.new(parse(argv)).run
    rescue Diccio::Error => e
      warn(e.message)
      exit(1)
    end

    def self.parse(argv)
      options = Options.new
      rest = parser(options).parse(argv)
      apply_word(options, rest)
      options
    rescue OptionParser::ParseError => e
      raise UsageError, e.message
    end

    def self.parser(options)
      OptionParser.new do |opts|
        opts.banner = 'Uso: diccio [opciones] <palabra>'
        history_option(opts, options)
        opts.on('--no-cache', 'Ignorar la base local y volver a pedir la palabra a la RAE') do
          options.cache = false
        end
        help_option(opts)
      end
    end

    def self.history_option(opts, options)
      opts.on('--history [FECHA]', 'Historial de palabras buscadas (FECHA en formato YYYY-MM-DD)') do |value|
        options.history = true
        options.date = parse_date(value, '--history') unless value.nil?
      end
    end

    def self.help_option(opts)
      opts.on('-h', '--help', 'Mostrar esta ayuda') do
        puts opts
        exit
      end
    end

    def self.apply_word(options, rest)
      return if options.history?
      raise UsageError, 'Falta palabra' if rest.empty?

      options.word = rest.first
    end

    def self.parse_date(value, flag)
      raise UsageError, invalid_date_message(value, flag) unless value.match?(DATE_PATTERN)

      Date.strptime(value, DATE_FORMAT)
    rescue Date::Error
      raise UsageError, invalid_date_message(value, flag)
    end

    def self.invalid_date_message(value, flag)
      "Fecha inválida en #{flag}: #{value} (formato esperado YYYY-MM-DD)"
    end
  end
end

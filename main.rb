#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'rae'

def main
  if ARGV.empty?
    puts 'Falta palabra'
    return
  end
  cli = RaeAPI.new
  puts cli.search(ARGV[0])
ensure
  cli&.close
end

main

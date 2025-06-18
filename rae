#!/usr/bin/env ruby

require_relative 'rae'

def main
  if ARGV.empty?
    puts 'Falta palabra'
    return
  end
  cli = RaeAPI.new
  puts cli.search(ARGV[0])
end

main

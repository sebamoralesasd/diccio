#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'rae'

def main
  cli = RaeAPI.new
  puts cli.search(ARGV[0])
rescue RaeApi::Error => e
  abort e.message
ensure
  cli&.close
end

abort 'Falta palabra' if ARGV.empty?

main

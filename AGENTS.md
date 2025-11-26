# AGENTS.md

## Build & Run Commands
- **Run**: `ruby main.rb <word>` - Search for a Spanish word definition
- **Install deps**: `bundle install`
- **Lint**: `rubocop` (no config file, uses defaults)
- **No tests**: This project has no test suite

## Code Style Guidelines
- **Ruby version**: 3.3.1, use `# frozen_string_literal: true` at top of library files
- **Imports**: Use `require_relative` for local files, `require` for gems (place gems after local requires)
- **Naming**: snake_case for methods/variables, PascalCase for classes/modules
- **Module structure**: `RaeApi` namespace in `lib/raeapi/`, main class `RaeAPI` in `rae.rb`
  - Note: `ClientDefaults` module in clientdefaults.rb is intentionally not namespaced (included via `include`)
- **Error handling**: Define custom errors inheriting from `StandardError` (see `RaeApi::Error`), raise without message when appropriate
- **Environment vars**: Use `ENV.fetch('KEY', default)` pattern for configuration
- **Control flow**: Prefer `return early` pattern for guard clauses, use `next unless` in loops
- **Accessors**: Use `attr_reader` instead of explicit getters
- **Organization**: Private methods grouped under `private` keyword at end of class
- **Modern syntax**: Hash shorthand `{ word: }` instead of `{ word: word }`, use trailing commas in multiline arrays/hashes
- **HTTP/CSV**: Use Faraday for HTTP requests (5s timeout default), CSV stdlib for database
- **Logging**: Use `puts 'LOG: ...'` for user-facing messages (Logger gem available but not currently used)

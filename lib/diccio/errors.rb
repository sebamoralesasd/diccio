# frozen_string_literal: true

module Diccio
  class Error < StandardError; end

  class ApiError < Error; end

  class NotFoundError < Error; end

  class DatabaseError < Error; end

  class UsageError < Error; end
end

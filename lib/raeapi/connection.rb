# frozen_string_literal: true

module RaeApi
  class Connection
    def initialize(base_url)
      @base_url = base_url
      @http_cli = connection
    end

    def get(params = nil)
      @http_cli.get do |req|
        req.options.timeout = 1
        req.params = params unless params.nil?
      end
    end

    private

    def connection
      Faraday.new(url: @base_url) do |faraday|
        faraday.adapter Faraday.default_adapter
        faraday.response :json
      end
    end
  end
end

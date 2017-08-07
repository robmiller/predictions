require "json"
require "typhoeus"

module Predictions
  class LeagueTable
    def initialize(api_url)
      @api_url = api_url
    end

    def table
      @table ||=
        begin
          fetch
          parse
        end
    end

    private

    def fetch
      response = Typhoeus.get(api_url)
      @json = response.body
    end

    def parse
      data = JSON.parse(json)
      data["standing"].map do |team|
        { position: team["position"], team: team["teamName"], points: team["points"] }
      end
    end

    attr_reader :api_url, :json
  end
end

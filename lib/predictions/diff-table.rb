require "text"

module Predictions
  class DiffTable
    def initialize(actual_table)
      @actual_table = actual_table
    end

    def diff(other_table)
      other_table.map do |guessed|
        real = actual_table.find { |p| p[:team] == guessed[:team] }

        # No exact match for this team. Are there any teams that have an
        # edit distance of <= 5 (i.e. missing an "FC", or something
        # simple like that)?
        unless real
          real = actual_table.find { |p| Text::Levenshtein.distance(p[:team], guessed[:team]) <= 5 }
        end

        # Still no match. Let's try White similarity
        unless real
          @white ||= Text::WhiteSimilarity.new
          real =
            actual_table
              .select  { |p| @white.similarity(p[:team], guessed[:team]) >= 0.5 }
              .sort_by { |p| @white.similarity(p[:team], guessed[:team]) }
              .last
        end

        unless real
          raise "No team name matched: I was given #{guessed[:team]}"
        end

        # Normalise team names
        guessed[:team] = real[:team].sub(/\s+FC/, "")

        guessed[:difference] = (real[:position] - guessed[:position]).abs
        guessed[:points_difference] = (real[:points] - guessed[:points]).abs
        guessed
      end
    end

    def score(other_table)
      diff(other_table).reduce(0) { |score, p| score + p[:difference] }
    end

    private

    attr_reader :actual_table
  end
end

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
      score = 0

      diff(other_table).each do |position|
        if position[:points_difference] == 0
          score -= 1
        else
          score += 0.1 * position[:points_difference]
        end

        if position[:difference] == 0
          score -= 1
        elsif position[:difference] == 1
          # noop
        else
          score += 1.2 * position[:difference]
        end
      end

      score.round
    end

    private

    attr_reader :actual_table
  end
end
